class Indicator < ApplicationRecord
  ALL_ATTRIBUTES = YAML.load_file(
    Rails.root.join('db', 'indicators_metadata.yml')
  ).freeze
  include MetadataAttributes

  ORDERS = %w[name category stack_family definition unit].freeze

  has_many :time_series_values, dependent: :destroy

  validates :name, presence: true

  class << self
    def fetch_all(order_options)
      order_direction = if order_options['order_direction'].present?
                          get_direction(order_options['order_direction'])
                        else
                          :asc
                        end

      order_type = get_type(order_options['order_type'])
      fetch_with_order(order_type, order_direction)
    end

    def fetch_with_order(order_type, order_direction)
      if order_type.present?
        Indicator.order(order_type => order_direction, name: :asc)
      else
        Indicator.order(name: :asc)
      end
    end

    def get_type(order_type)
      ORDERS.include?(order_type) && order_type
    end

    def get_direction(direction)
      direction == 'desc' ? :desc : :asc
    end
  end

  def time_series_data?
    time_series_values.any?
  end

  # TODO: validate comparable indicator has convertible unit
  # TODO: unit conversions
end
