class FilterTimeSeriesValues
  ORDER_COLUMNS = %w[scenario location unit_of_entry].freeze

  include ActiveModel::Model

  attr_writer :order_type, :order_direction
  attr_accessor :search

  def call(scope)
    format_pivot_result(
      scope.
        merge(search_scope).
        merge(order_scope)
    )
  end

  def order_type
    @order_type if ORDER_COLUMNS.include?(@order_type)
  end

  def order_direction
    @order_direction.to_s.casecmp('desc').zero? ? :desc : :asc
  end

  private

  def format_pivot_result(scope)
    pivot = TimeSeriesYearPivotQuery.new(scope)
    query_sql = pivot.query_with_order(order_type, order_direction)
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

  def time_series_values
    TimeSeriesValue.all
  end

  def search_scope
    return time_series_values if search.blank?

    time_series_values.search_for(search).except(:order)
  end

  def order_scope
    return time_series_values if order_type.blank?

    time_series_values.order(order_type => order_direction, name: :asc)
  end
end
