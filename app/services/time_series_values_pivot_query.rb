class TimeSeriesValuesPivotQuery
  module Transformations
    def years
      Array.wrap(column_types.keys[5..-1])
    end

    def to_pivot
      {
        years: years,
        data: map do |tsv|
          {
            scenario_name: tsv['scenario_name'],
            location_name: tsv['location_name'],
            values: years.map { |y| tsv[y] }
          }
        end
      }
    end

    def to_summary
      transformer = lambda do |value|
        available_years = value.inject([]) do |result, v|
          result + years.select { |y| v[y].present? }
        end
        {
          locations: value.map { |v| v['location_name'] }.uniq.sort,
          years: [available_years.first, available_years.last]
        }
      end

      group_by { |tsv| [tsv['model_abbreviation'], tsv['scenario_name']] }.
        transform_values(&transformer).
        map { |key, value| {model: key.first, scenario: key.second}.merge(value) }
    end
  end

  attr_accessor :query

  def initialize(query)
    @query = query
  end

  def call
    ActiveRecord::Base.connection.exec_query(sql).extend(Transformations)
  end

  private

  def columns
    %w[model_abbreviation scenario_name location_name indicator_name unit_of_entry] +
      years.map { |year| %["#{year}"] }
  end

  def sql
    "SELECT #{columns.join(',')} FROM (#{crosstab_query}) s"
  end

  def years_query
    query.select(:year).reorder(:year).distinct
  end

  def years
    @years ||= years_query.pluck(:year)
  end

  def column_names
    [
      'CONCAT(models.id,indicators.id,scenarios.id,locations.id) AS row_no',
      'models.abbreviation',
      'scenarios.name AS scenario_name',
      'locations.name AS region',
      'indicators.composite_name AS indicator_name',
      'indicators.unit AS unit_of_entry',
      'year',
      'round(value, 4) AS value'
    ]
  end

  def main_query
    query.
      joins(:indicator, :location, scenario: :model).
      select(column_names).
      reorder(
        'models.abbreviation',
        'scenarios.name',
        'indicators.composite_name',
        'locations.name'
      )
  end

  def crosstab_query
    years_output_column_names = years.map { |year| %["#{year}" numeric] }

    output_columns = [
      'row_no text',
      'model_abbreviation text',
      'scenario_name text',
      'location_name text',
      'indicator_name text',
      'unit_of_entry text'
    ] + years_output_column_names

    sql = "SELECT * FROM crosstab(?, ?) AS ct(#{output_columns.join(',')})"

    ActiveRecord::Base.send(
      :sanitize_sql_array,
      [sql, main_query.to_sql, years_query.to_sql]
    )
  end
end
