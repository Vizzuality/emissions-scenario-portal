class Location < ApplicationRecord
  validates :name, presence: true

  ORDERS = %w[name region].freeze

  class << self
    def fetch_all(options)
      locations = Location
      options.each_with_index do |filter|
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
        locations.where('lower(name) LIKE ?', "%#{value.downcase}%")
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
