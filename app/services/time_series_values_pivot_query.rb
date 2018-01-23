class TimeSeriesValuesPivotQuery
  attr_accessor :query

  def initialize(query)
    @query = query
  end

  def call
    ActiveRecord::Base.connection.exec_query(sql)
  end

  private

  def columns
    %w[model_abbreviation scenario_name location_name indicator_name] +
      years.map { |year| %Q["#{year}"] }
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
      'year',
      'value'
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
    years_output_column_names = years.map { |year| %Q["#{year}" numeric] }

    output_columns = [
      'row_no text',
      'model_abbreviation text',
      'scenario_name text',
      'location_name text',
      'indicator_name text',
    ] + years_output_column_names

    sql = "SELECT * FROM crosstab(?, ?) AS ct(#{output_columns.join(',')})"

    ActiveRecord::Base.send(
      :sanitize_sql_array,
      [sql, main_query.to_sql, years_query.to_sql]
    )
  end
end
