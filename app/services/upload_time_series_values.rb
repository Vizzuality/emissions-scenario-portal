class UploadTimeSeriesValues
  include ActiveModel::Model
  attr_reader :csv_upload

  HEADERS = {
    model: 'Model',
    scenario: 'Scenario',
    location: 'Region',
    indicator: 'ESP Indicator Name',
    unit: 'Unit of Entry'
  }.freeze

  def initialize(csv_upload)
    @csv_upload = csv_upload
  end

  def call
    if valid_headers?(HEADERS)
      rows = parse_rows
      # remove empty rows
      rows = rows.reject { |row| row.except(:row).values.all?(:blank?) }

      # skip rows with missing associations
      rows = skip_incomplete(rows)

      # prevent overwriting the same records more than once
      rows = skip_duplicate(rows)

      # inject proper conversion factors if necessary
      rows = inject_conversion_factors(rows)

      # convert rows to attrs
      attrs_list = parse_years(rows)

      # remove attrs with blank values
      attrs_list = attrs_list.reject { |attrs| attrs[:value].blank? }

      # convert units using injected conversion factors
      attrs_list = convert_values(attrs_list)

      records = attrs_list.map do |attrs|
        TimeSeriesValue.new(
          attrs.slice(:scenario, :indicator, :location, :year, :value)
        )
      end
    end

    ActiveRecord::Base.transaction do
      result = import(records || [])

      csv_upload.update!(
        success: errors.blank?,
        finished_at: Time.current,
        errors_and_warnings: {errors: errors.details[:base]},
        number_of_records_saved: result.ids.size
      )
    end

    csv_upload
  end

  private

  def csv
    return @csv if defined?(@csv)
    file = Paperclip.io_adapters.for(csv_upload.data)
    encoding = CharlockHolmes::EncodingDetector.detect(file.read)[:encoding]
    @csv = CSV.open(file.path, 'r', headers: true, encoding: encoding).read
  end

  def parse_headers(headers)
    csv.headers.map do |header|
      HEADERS.
        transform_values(&:downcase).
        key(header.to_s.downcase.gsub(/\s+/, ' ').strip) || header
    end
  end

  def valid_headers?(headers)
    (headers.keys - parse_headers(headers)).each do |value|
      errors.add(:base, :missing_header, msg: "Missing header #{value}", row: 1)
    end
  end

  def add_error(type, message, attrs = {})
    errors.add(:base, type, msg: message, **attrs)
    false
  end

  def models
    @models ||= Hash.new do |hash, model_abbreviation|
      hash[model_abbreviation] =
        Pundit.
          policy_scope(csv_upload.user, Model).
          find_by_abbreviation(model_abbreviation)
    end
  end

  def scenarios
    @scenarios ||= Hash.new do |hash, (model, scenario_name)|
      hash[[model, scenario_name]] =
        model&.scenarios&.find_by_name(scenario_name)
    end
  end

  def indicators
    @indicators ||= Hash.new do |hash, indicator_name|
      hash[indicator_name] =
        Indicator.find_by_name(indicator_name)
    end
  end

  def locations
    @locations ||= Hash.new do |hash, location_name|
      hash[location_name] =
        Location.find_by_name_or_iso_code(location_name)
    end
  end

  def notes
    @notes ||= Hash.new do |hash, (model, indicator)|
      hash[[model, indicator]] =
        Note.find_by(model: model, indicator: indicator)
    end
  end

  def parse_rows
    csv.map.with_index(2) do |csv_row, line_number|
      parse_headers(HEADERS).zip(csv_row.fields).to_h.tap do |row|
        if models[row[:model]].present?
          row[:model] = models[row[:model]]
          row[:scenario] = scenarios[[row[:model], row[:scenario]]] || row[:scenario]
        end
        row[:indicator] = indicators[row[:indicator]] || row[:indicator]
        row[:location] = locations[row[:location]] || row[:location]
        row[:row] = line_number
      end
    end
  end

  def skip_incomplete(rows)
    rows.select do |row|
      unless row[:model].is_a?(Model)
        error = add_error(
          :model_not_found,
          "Model does not exist #{row[:model]}",
          row.slice(:row)
        )
      end

      unless row[:scenario].is_a?(Scenario)
        error = add_error(
          :scenario_not_found,
          "Scenario does not exist #{row[:scenario]}",
          row.slice(:row)
        )
      end

      unless row[:indicator].is_a?(Indicator)
        error = add_error(
          :indicator_not_found,
          "Indicator does not exist #{row[:indicator]}",
          row.slice(:row)
        )
      end

      unless row[:location].is_a?(Location)
        error = add_error(
          :location_not_found,
          "Location does not exist #{row[:location]}",
          row.slice(:row)
        )
      end

      error.nil?
    end
  end

  def skip_duplicate(rows)
    set = Set.new
    rows.select do |row|
      if set.add?(row.values_at(:scenario, :indicator, :location))
        true
      else
        add_error(
          :duplicate_row,
          "Unable to import rows overwriting already imported records",
          row.slice(:row)
        )
      end
    end
  end

  def inject_conversion_factors(rows)
    rows.select do |row|
      if row[:unit] == row[:indicator].unit
        row[:conversion_factor] = 1.0
      else
        note = notes[[row[:model], row[:indicator]]]

        if row[:unit] == note&.unit_of_entry
          row[:conversion_factor] = note.conversion_factor
        else
          error = add_error(
            :inconvertible_unit,
            "Inconvertible unit #{row[:unit]}",
            row.slice(:row)
          )
        end
      end

      error.nil?
    end
  end

  def parse_years(rows)
    rows.each.with_object([]) do |row, results|
      row.except(*HEADERS.keys, *%i[conversion_factor row]).each do |year, value|
        results.push(
          year: year,
          value: value,
          col: row.keys.index(year) + 1,
          **row.slice(:scenario, :indicator, :location, :row, :conversion_factor),
        )
      end
    end
  end

  def convert_values(attrs_list)
    attrs_list.select do |attrs|
      attrs[:value] =
        BigDecimal(attrs[:value]) * attrs[:conversion_factor]
    rescue ArgumentError
      add_error(
        :unparseable_value,
        "Unable to parse value #{attrs[:value]}",
        attrs.slice(:row, :col)
      )
      false
    end
  end

  def import(records)
    TimeSeriesValue.import(
      records,
      on_duplicate_key_update: {
        conflict_target: %i[scenario_id indicator_id location_id year],
        columns: %i[value],
        validate: false
      }
    )
  end
end
