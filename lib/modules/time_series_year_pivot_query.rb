class TimeSeriesYearPivotQuery
  def initialize(original_query)
    @main_query = original_query.
      joins(:indicator, {scenario: :model}, :location).
      select(TimeSeriesYearPivotQuery.column_names).
      order('scenarios.name', 'indicators.alias', 'locations.name')
    @years_query = original_query.select(:year).order(:year).distinct
  end

  def query
    columns = TimeSeriesYearPivotQuery.column_aliases + year_column_headers
    "SELECT #{columns.join(',')} FROM (#{crosstab_query}) s"
  end

  def years
    @years_query.pluck(:year)
  end

  def all_column_headers
    TimeSeriesYearPivotQuery.column_headers + year_column_headers
  end

  private

  def year_column_headers
    years.map { |y| "\"#{y}\"" }
  end

  def crosstab_query
    years_output_column_names = years.map { |y| "\"#{y}\" numeric" }
    output_column_names = [
      'row_no int[]',
      'model_abbreviation text',
      'scenario_name text',
      'region text',
      'indicator_name text',
      'unit_of_entry text'
    ] + years_output_column_names
    <<~SQL
      SELECT *
      FROM crosstab(
        '#{@main_query.to_sql}',
        '#{@years_query.to_sql}'
      )
      AS ct(
        #{output_column_names.join(',')}
      )
    SQL
  end

  class << self
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

    def column_aliases
      TimeSeriesValuesHeaders::EXPECTED_HEADERS.map do |eh|
        eh[:property_name]
      end
    end

    def column_headers
      TimeSeriesValuesHeaders::EXPECTED_HEADERS.map do |eh|
        eh[:display_name]
      end
    end
  end
end
