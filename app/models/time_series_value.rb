class TimeSeriesValue < ApplicationRecord
  belongs_to :scenario, counter_cache: true
  belongs_to :indicator, counter_cache: true
  belongs_to :location

  validates(
    :year,
    presence: true,
    numericality: {only_integer: true, allow_nil: true},
    inclusion: {in: 1900..3000, allow_nil: true}
  )
  validates :value, presence: true, numericality: {allow_nil: true}

  def self.time_series_values_pivot
    results = TimeSeriesValuesPivotQuery.new(self).call
    years = Array.wrap(results.column_types.keys[4..-1])

    {
      years: years,
      data: results.map do |tsv|
        {
          scenario_name: tsv['scenario_name'],
          location_name: tsv['location_name'],
          values: years.map { |y| tsv[y] }
        }
      end
    }
  end

  def self.time_series_values_summary
    results = TimeSeriesValuesPivotQuery.new(self).call
    years = Array.wrap(results.column_types.keys[4..-1])

    results.
      group_by { |tsv| [tsv['model_abbreviation'], tsv['scenario_name']] }.
      transform_values do |value|
        years = value.inject([]) do |result, v|
          result + years.select { |y| v[y].present? }
        end
        {
          locations: value.map { |v| v['location_name'] },
          years: [years.first, years.last]
        }
      end.
      map { |key, value| {model: key.first, scenario: key.second}.merge(value) }
  end

  def note
    Note.find_by(model_id: scenario.model_id, indicator_id: indicator.id)
  end
end
