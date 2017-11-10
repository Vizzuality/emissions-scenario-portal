class FilterScenarios
  ORDER_COLUMNS = %w[name updated_at time_series indicators].freeze

  include ActiveModel::Model

  attr_writer :order_type, :order_direction
  attr_accessor :search

  def call(scope)
    scope.
      merge(search_scope).
      merge(order_scope)
  end

  def order_type
    @order_type if ORDER_COLUMNS.include?(@order_type)
  end

  def order_direction
    @order_direction.to_s.casecmp('desc').zero? ? :desc : :asc
  end

  private

  def scenarios
    Scenario.all
  end

  def search_scope
    return scenarios if search.blank?

    scenarios.where('lower(name) LIKE ?', "%#{search.downcase}%")
  end

  def order_scope
    return scenarios if order_type.blank?

    case order_type
    when 'indicators'
      scenarios.time_series.order("count(indicator_id) #{order_direction}")
    when 'time_series'
      scenarios.time_series_order(order_direction)
    else
      scenarios.order(order_type => order_direction, name: :asc)
    end
  end
end