class UploadTimeSeriesValues
  include ActiveModel::Model
  include UploadService

  private

  def headers
    {
      model: 'Model',
      scenario: 'Scenario',
      location: 'Region',
      indicator: 'ESP Indicator Name',
      unit_of_entry: 'Unit of Entry'
    }
  end

  def import
    records = csv.map.with_index(2) do |row, line_number|
      attributes = parsed_csv_headers.zip(row.fields).to_h

      model = find_model(attributes[:model])
      scenario = model&.scenarios&.find_by_name(attributes[:scenario])
      indicator = Indicator.find_by_name(attributes[:indicator])
      location = Location.find_by_name(attributes[:location])
      unit_of_entry = attributes[:unit_of_entry]

      attributes.except(*headers.keys).map do |year, value|
        next if value.nil?

        TimeSeriesValue.new(
          scenario: scenario,
          indicator: indicator,
          location: location,
          year: year,
          value: value
        ) do |time_series_value|
          time_series_value.define_singleton_method(:row) { line_number }
          time_series_value.define_singleton_method(:col) { row.headers.index(year) + 1 }
        end
      end
    end

    TimeSeriesValue.import(
      records.flatten.compact,
      on_duplicate_key_update: {
        conflict_target: %i[scenario_id indicator_id location_id year],
        columns: %i[value]
      }
    )
  end

  def find_model(model_abbreviation)
    Pundit.
      policy_scope(csv_upload.user, Model).
      find_by_abbreviation(model_abbreviation)
  end
end
