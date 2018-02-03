class UploadTimeSeriesValues
  include ActiveModel::Model
  include UploadService

  def self.headers
    {
      model: 'Model',
      scenario: 'Scenario',
      location: 'Region',
      indicator: 'ESP Indicator Name',
      unit: 'Unit of Entry'
    }
  end

  def call
    if valid?
      rows = parse_rows
      rows = rows.reject { |row| row.except(:row).values.all?(:blank?) }
      rows = skip_incomplete(rows)
      rows = remove_duplicate(rows)
      rows = fetch_conversion_factors(rows)
      attributes_list = parse_years(rows)
      attributes_list = attributes_list.select { |attributes| attributes[:value].present? }
      attributes_list = convert_values(attributes_list)
      records = attributes_list.map { |attributes| TimeSeriesValue.new(attributes.slice(:scenario, :indicator, :location, :year, :value)) }
    end

    ActiveRecord::Base.transaction do
      result = import(records || [])
      update_csv_upload(result)
    end

    csv_upload
  end

  private

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
      parsed_csv_headers.zip(csv_row.fields).to_h.tap do |row|
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
        error = errors.add(
          :csv_upload,
          :invalid,
          msg: "Model does not exist #{row[:model]}",
          row: row[:row],
          type: :record
        )
      end

      unless row[:scenario].is_a?(Scenario)
        error = errors.add(
          :csv_upload,
          :invalid,
          msg: "Scenario does not exist #{row[:scenario]}",
          row: row[:row],
          type: :record
        )
      end

      unless row[:indicator].is_a?(Indicator)
        error = errors.add(
          :csv_upload,
          :invalid,
          msg: "Indicator does not exist #{row[:indicator]}",
          row: row[:row],
          type: :record
        )
        false
      end

      unless row[:location].is_a?(Location)
        error = errors.add(
          :csv_upload,
          :invalid,
          msg: "Location does not exist #{row[:location]}",
          row: row[:row],
          type: :record
        )
        false
      end

      error.nil?
    end
  end

  def remove_duplicate(rows)
    set = Set.new
    rows.select do |row|
      unless set.add?(row.values_at(:scenario, :indicator, :location))
        error = errors.add(
          :csv_upload,
          :invalid,
          msg: "Unable to import rows overwriting already imported records",
          row: row[:row],
          type: :record
        )
      end

      error.nil?
    end
  end

  def fetch_conversion_factors(rows)
    rows.select do |row|
      if row[:unit] == row[:indicator].unit
        row[:conversion_factor] = 1.0
      else
        note = notes[[row[:model], row[:indicator]]]

        if row[:unit] == note&.unit_of_entry
          row[:conversion_factor] = note.conversion_factor
        else
          error = errors.add(
            :csv_upload,
            :invalid,
            msg: "Inconvertible unit #{row[:unit]}",
            row: row[:row],
            type: :record
          )
        end
      end

      error.nil?
    end
  end

  def parse_years(rows)
    rows.each.with_object([]) do |row, results|
      row.except(*self.class.headers.keys, *%i[conversion_factor]).each do |year, value|
        results.push(
          year: year,
          value: value,
          col: row.keys.index(year) + 1,
          **row.slice(:scenario, :indicator, :location, :row, :conversion_factor),
        )
      end
    end
  end

  def convert_values(attributes_list)
    attributes_list.select do |attributes|
      attributes[:value] =
        BigDecimal(attributes[:value]) * attributes[:conversion_factor]
    rescue ArgumentError
      errors.add(
        :csv_upload,
        :invalid,
        msg: "Unable to parse value #{attributes[:value]}",
        row: attributes[:row],
        col: attributes[:col],
        type: :record
      )
      false
    end
  end

  def import(records)
    TimeSeriesValue.import(
      records,
      on_duplicate_key_update: {
        conflict_target: %i[scenario_id indicator_id location_id year],
        columns: %i[value]
      }
    )
  end
end
