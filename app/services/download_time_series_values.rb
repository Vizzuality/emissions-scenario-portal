class DownloadTimeSeriesValues
  def initialize(user)
    @user = user
  end

  def call(data)
    sql = data.
      joins(:indicator, {scenario: :model}, :location).
      select(select_columns).
      to_sql
    PgCsv.new(
      columns: columns,
      sql: sql,
      type: :plain
    )
  end

  def columns
    TimeSeriesValuesHeaders::EXPECTED_HEADERS.map do |eh|
      eh[:display_name]
    end + %w(Year Value)
  end

  def select_columns
    select_columns = TimeSeriesValuesHeaders::EXPECTED_HEADERS.map do |eh|
      eh[:property_name]
    end + [:year, :value]
    select_columns[
      select_columns.index(:model_abbreviation)
    ] = 'models.abbreviation'
    select_columns[select_columns.index(:scenario_name)] = 'scenarios.name'
    select_columns[select_columns.index(:indicator_name)] = 'indicators.name'
    select_columns[select_columns.index(:region)] = 'locations.name'
    select_columns
  end
end
