class UploadTimeSeriesValues
  include ActiveModel::Model
  include CsvParsingHelpers
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
      rows = sanitize_rows(rows)
      attrs = build_import_attributes(rows)
      records = build_records(attrs)
    end
    perform_import(records || [])
    csv_upload
  end

  private

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

  def sanitize_rows(rows)
    set = Set.new

    rows.select do |row|
      # remove empty rows
      row.except(:row).values.any?(&:present?) &&
        # skip rows with missing associations
        skip_incomplete(row, :model) &&
        skip_incomplete(row, :scenario) &&
        skip_incomplete(row, :indicator) &&
        skip_incomplete(row, :location) &&
        # prevent overwriting the same records more than once
        skip_duplicate(set, row, %i[model scenario indicator location]) &&
        # inject proper conversion factors if necessary
        inject_conversion_factors(row)
    end
  end

  def inject_conversion_factors(row)
    if row[:unit] == row[:indicator].unit
      row[:conversion_factor] = 1.0
    else
      note = notes[[row[:model], row[:indicator]]]

      if row[:unit] == note&.unit_of_entry
        row[:conversion_factor] = note.conversion_factor
      else
        return add_error(
          :inconvertible_unit,
          "Inconvertible unit #{row[:unit]}",
          row.slice(:row)
        )
      end
    end
    true
  end

  def build_import_attributes(rows)
    # convert rows to attrs
    attrs_list = parse_years(rows)

    # remove attrs with blank values
    attrs_list = attrs_list.reject { |attrs| attrs[:value].blank? }

    # convert units using injected conversion factors
    attrs_list = convert_values(attrs_list)
  end

  def build_records(attrs_list)
    attrs_list.map do |attrs|
      TimeSeriesValue.new(
        attrs.slice(:scenario, :indicator, :location, :year, :value)
      )
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

  def update_indicator_counters
    indicators.values.compact.each do |indicator|
      Indicator.reset_counters(indicator.id, :time_series_values)
    end
  end

  def update_scenario_counters
    scenarios.values.compact.each do |scenario|
      Scenario.reset_counters(scenario.id, :time_series_values)
    end
  end

  def perform_import(records)
    ActiveRecord::Base.transaction do
      result = TimeSeriesValue.import(
        records,
        on_duplicate_key_update: {
          conflict_target: %i[scenario_id indicator_id location_id year],
          columns: %i[value],
          validate: false
        }
      )

      update_indicator_counters
      update_scenario_counters

      csv_upload.update!(
        success: errors.blank?,
        finished_at: Time.current,
        errors_and_warnings: {errors: errors.details[:base]},
        number_of_records_saved: result.ids.size
      )
    end
  end
end
