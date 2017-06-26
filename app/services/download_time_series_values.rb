class DownloadTimeSeriesValues
  def initialize(user)
    @user = user
  end

  def call(data)
    years_query = data.select(:year).order(:year).distinct
    main_query = data.
      joins(:indicator, {scenario: :model}, :location).
      select(column_names).
      order('scenarios.name', 'indicators.alias', 'locations.name')

    PgCsv.new(
      columns: column_headers + year_column_headers(years_query),
      sql: csv_query(main_query, years_query),
      type: :plain
    )
  end

  private

  def csv_query(main_query, years_query)
    <<~SQL
      SELECT #{(column_aliases + year_column_headers(years_query)).join(',')}
      FROM (#{crosstab_query(main_query, years_query)}) s
    SQL
  end

  def crosstab_query(main_query, years_query)
    years_output_column_names = years_query.pluck(:year).
      map { |y| "\"#{y}\" numeric" }.join(', ')
    <<~SQL
      SELECT *
      FROM crosstab(
        '#{main_query.to_sql}',
        '#{years_query.to_sql}'
      )
      AS ct(
        row_no int[],
        model_abbreviation text,
        scenario_name text,
        region text,
        indicator_name text,
        unit_of_entry text,
        #{years_output_column_names}
      )
    SQL
  end

  def column_headers
    TimeSeriesValuesHeaders::EXPECTED_HEADERS.map do |eh|
      eh[:display_name]
    end
  end

  def year_column_headers(years_query)
    years_query.pluck(:year).map { |y| "\"#{y}\"" }
  end

  def column_aliases
    TimeSeriesValuesHeaders::EXPECTED_HEADERS.map do |eh|
      eh[:property_name]
    end
  end

  def column_names
    column_names = [
      'ARRAY[indicator_id, scenario_id, location_id]::INT[] AS rowno'
    ] + column_aliases + [:year, :value]
    column_names[
      column_names.index(:model_abbreviation)
    ] = 'models.abbreviation'
    column_names[
      column_names.index(:scenario_name)
    ] = 'scenarios.name AS scenario_name'
    column_names[
      column_names.index(:indicator_name)
    ] = 'indicators.alias AS indicator_name'
    column_names[column_names.index(:region)] = 'locations.name AS region'
    column_names
  end
end
