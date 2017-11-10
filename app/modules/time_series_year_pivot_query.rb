class TimeSeriesYearPivotQuery
  def initialize(original_query)
    @main_query = original_query.
      joins(
        "INNER JOIN indicators indicators_pivot
ON indicators_pivot.id = time_series_values.indicator_id"
      ).
      joins(
        "INNER JOIN scenarios scenarios_pivot
ON scenarios_pivot.id = time_series_values.scenario_id"
      ).
      joins(
        "INNER JOIN models models_pivot
ON models_pivot.id = scenarios_pivot.model_id"
      ).
      joins(
        "INNER JOIN locations locations_pivot
ON locations_pivot.id = time_series_values.location_id"
      ).
      select(TimeSeriesYearPivotQuery.column_names).
      order(
        'scenarios_pivot.name', 'indicators_pivot.alias',
        'locations_pivot.name', 'time_series_values.unit_of_entry'
      )
    @years_query = original_query.select(:year).except(:order).order(:year).
      distinct
  end

  def query
    "SELECT #{all_column_aliases.join(',')} FROM (#{crosstab_query}) s"
  end

  def query_with_order(order_type, order_direction)
    order_direction = 'asc' unless order_direction &&
        %w(asc desc).include?(order_direction)
    if TimeSeriesYearPivotQuery.column_aliases.map(&:to_s).
        include?(order_type) ||
        years.map(&:to_s).include?(order_type)
      "SELECT #{all_column_aliases.join(',')} FROM (#{crosstab_query}) s
ORDER BY \"#{order_type}\" #{order_direction}"
    else
      query
    end
  end

  def years
    @years_query.pluck(:year)
  end

  def all_column_aliases
    TimeSeriesYearPivotQuery.column_aliases + year_column_headers
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
      'row_no text[]',
      'model_abbreviation text',
      'scenario_name text',
      'location_name text',
      'indicator_name text',
      'unit_of_entry text'
    ] + years_output_column_names
    sql = "SELECT * FROM crosstab(?, ?) AS ct(#{output_column_names.join(',')})"
    ActiveRecord::Base.send(
      :sanitize_sql_array,
      [
        sql,
        @main_query.to_sql,
        @years_query.to_sql
      ]
    )
  end

  class << self
    def column_names
      grouping_columns = [
        'indicators_pivot.name',
        'scenarios_pivot.name',
        'locations_pivot.name',
        'time_series_values.unit_of_entry'
      ]
      column_names = [
        "ARRAY[#{grouping_columns.join(',')}]::TEXT[] AS row_no"
      ] + column_aliases + [:year, :value]
      column_names[
        column_names.index(:model_abbreviation)
      ] = 'models_pivot.abbreviation'
      column_names[
        column_names.index(:scenario_name)
      ] = 'scenarios_pivot.name AS scenario_name'
      column_names[
        column_names.index(:indicator_name)
      ] = 'indicators_pivot.alias AS indicator_name'
      column_names[
        column_names.index(:location_name)
      ] = 'locations_pivot.name AS region'
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
