class FilterLocations
  cattr_reader :order_columns do
    %w[name iso_code region].freeze
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
