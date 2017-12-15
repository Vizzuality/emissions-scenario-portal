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
    pivot = TimeSeriesYearPivotQuery.new(self)
    query_sql = pivot.query_with_order(nil, nil)
    result = TimeSeriesValue.find_by_sql(query_sql)

    {
      years: pivot.years,
      data: result.map do |tsv|
        {
          scenario_name: tsv['scenario_name'],
          location_name: tsv['location_name'],
          unit_of_entry: tsv['unit_of_entry'],
          values: pivot.years.map { |y| tsv[y] }
        }
      end
    }
  end

  def self.time_series_values_summary
    pivot = TimeSeriesYearPivotQuery.new(self)
    query_sql = pivot.query_with_order(nil, nil)

    TimeSeriesValue.
      find_by_sql(query_sql).
      group_by { |tsv| [tsv['model_abbreviation'], tsv['scenario_name']] }.
      transform_values do |value|
        years = value.inject([]) do |result, v|
          result + pivot.years.select { |y| v[y].present? }
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
