class TimeSeriesYearPivotQuery
  attr_reader :original_query

  def initialize(original_query)
    @original_query = original_query
  end

  def query
    "SELECT #{all_column_aliases.join(',')} FROM (#{crosstab_query}) s"
  end

  def years
    years_query.pluck(:year)
  end

  def all_column_headers
    column_headers + year_column_headers
  end

  private

  def main_query
    original_query.
      joins(:indicator, :location, scenario: :model).
      select(column_names).
      reorder(
        'models.abbreviation',
        'scenarios.name',
        'indicators.composite_name',
        'locations.name'
      )
  end

  def years_query
    original_query.select(:year).reorder(:year).distinct
  end

  def all_column_aliases
    column_aliases + year_column_headers
  end

  def year_column_headers
    years.map { |y| %Q["#{y}"] }
  end

  def crosstab_query
    years_output_column_names = years.map { |y| %Q["#{y}" numeric] }
    output_column_names = [
      'row_no text',
      'model_abbreviation text',
      'scenario_name text',
      'location_name text',
      'indicator_name text',
    ] + years_output_column_names

    sql = "SELECT * FROM crosstab(?, ?) AS ct(#{output_column_names.join(',')})"

    ActiveRecord::Base.send(
      :sanitize_sql_array,
      [sql, main_query.to_sql, years_query.to_sql]
    )
  end

  private

  def column_names
    [
      'CONCAT(models.id,indicators.id,scenarios.id,locations.id) AS row_no',
      'models.abbreviation',
      'scenarios.name AS scenario_name',
      'locations.name AS region',
      'indicators.composite_name AS indicator_name',
      'year',
      'value'
    ]
  end

  def column_aliases
    %i[model_abbreviation scenario_name location_name indicator_name]
  end

  def column_headers
    ["Model", "Scenario", "Region", "ESP Indicator Name"]
  end
end
