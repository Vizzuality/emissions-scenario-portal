class FilterScenarios
  cattr_reader :order_columns do
    %w[name updated_at time_series indicators].freeze
  end

  include ActiveModel::Model
  include OrderableFilter

  attr_accessor :search

  def call(scope)
    scope.
      merge(search_scope).
      merge(order_scope)
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
