class FilterLocations
  ORDER_COLUMNS = %w[name iso_code region].freeze

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

  def locations
    Location.all
  end

  def search_scope
    return locations if search.blank?

    locations.where(
      'lower(name) LIKE :name OR lower(iso_code) LIKE :name',
      name: "%#{search.downcase}%"
    )
  end

  def order_scope
    return locations if order_type.blank?

    locations.order(order_type => order_direction, name: :asc)
  end
end
