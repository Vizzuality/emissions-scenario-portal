class Indicator < ApplicationRecord
  ALL_ATTRIBUTES = YAML.load_file(
    Rails.root.join('db', 'indicators_metadata.yml')
  ).freeze
  include MetadataAttributes

  ORDERS = %w[name category stack_family definition unit].freeze

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
      search = options['search'] if options['search'].present?
      if options['order_type'].present?
        order_direction = if options['order_direction'].present?
                            get_direction(options['order_direction'])
                          else
                            :asc
                          end

        order_type = get_type(options['order_type'])
      end

      indicators = Indicator
      indicators = indicators.where("name LIKE '%#{search}%'") if search.present?
      indicators = fetch_with_order(indicators, order_type, order_direction) if order_type.present?
      indicators = Indicator.order(name: :asc) if not(order_type.present?)
      indicators
    end

    def fetch_with_order(indicators, order_type, order_direction)
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
