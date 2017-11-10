class Location < ApplicationRecord
  validates :name, presence: true
  validates :iso_code, presence: true, length: {maximum: 2}, unless: :region?

  ORDERS = %w[name iso_code region].freeze

  class << self
    def fetch_all(options)
      locations = Location.all
      options.each do |filter|
        locations = apply_filter(locations, options, filter[0], filter[1])
      end
      unless options['order_type'].present?
        locations = locations.order(name: :asc)
      end
      locations
    end

    def apply_filter(locations, options, filter, value)
      case filter
      when 'search'
        locations.where(
          'lower(name) LIKE :name OR lower(iso_code) LIKE :name',
          name: "%#{value.downcase}%"
        )
      when 'order_type'
        fetch_with_order(
          locations,
          value,
          options['order_direction']
        )
      else
        locations
      end
    end

    def fetch_with_order(locations, order_type, order_direction)
      order_direction = get_order_direction(order_direction)
      order_type = get_order_type(ORDERS, order_type)

      locations.order(order_type => order_direction, name: :asc)
    end
  end
end
