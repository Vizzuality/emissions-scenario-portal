class Indicator < ApplicationRecord
  ALL_ATTRIBUTES = YAML.load_file(
    Rails.root.join('db', 'indicators_metadata.yml')
  ).freeze
  include MetadataAttributes

  ORDERS = %w[name category stack_family definition unit].freeze
  CATEGORIES = %w[Energy Fuel].freeze

  has_many :time_series_values, dependent: :destroy

  validates :name, presence: true

  def scenarios
    Scenario.joins(
      "JOIN (
        #{time_series_values.select(:scenario_id).group(:scenario_id).to_sql}
      ) s ON scenarios.id = s.scenario_id"
    )
  end

  def models
    scenarios.joins(:model).map(&:model)
  end

  class << self
    def fetch_all(options)
      indicators = Indicator
      options.each_with_index do |filter|
        indicators = apply_filter(indicators, options, filter[0], filter[1])
      end
      unless options['order_type'].present?
        indicators = indicators.order(name: :asc)
      end
      indicators
    end

    def apply_filter(indicators, options, filter, value)
      return indicators.where("#{filter} = '#{value}'") if ['category'].include? filter

      case filter
      when 'search'
        indicators.where("name LIKE '%#{value}%'")
      when 'order_type'
        fetch_with_order(
          indicators,
          value,
          options['order_direction']
        )
      else
        indicators
      end
    end

    def fetch_with_order(indicators, order_type, order_direction)
      order_direction = get_direction(order_direction)
      order_type = get_type(order_type)

      indicators.order(order_type => order_direction, name: :asc)
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
