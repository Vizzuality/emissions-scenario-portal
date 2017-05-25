class Scenario < ApplicationRecord
  ALL_ATTRIBUTES = YAML.load_file(
    Rails.root.join('db', 'scenarios_metadata.yml')
  ).freeze
  include MetadataAttributes

  belongs_to :model
  has_many :time_series_values, dependent: :destroy
  has_many :indicators, through: :time_series_values

  validates :name, presence: true
  # TODO: validate release date is a date
  before_validation :ignore_blank_array_values

  delegate :abbreviation, to: :model, prefix: :model

  scope :time_series, (lambda do
    joins('LEFT JOIN "time_series_values"
      ON "time_series_values"."scenario_id" = "scenarios"."id"').
      group('scenarios.id')
  end)

  ORDERS = %w[name updated_at time_series indicators].freeze

  def meta_data?
    # TODO: what to check here?
    true
  end

  def time_series_data?
    time_series_values.any?
  end

  class << self
    def fetch_all(options)
      scenarios = Scenario
      options.each_with_index do |filter|
        scenarios = apply_filter(scenarios, options, filter[0], filter[1])
      end
      unless options['order_type'].present?
        scenarios = scenarios.order(name: :asc)
      end
      scenarios
    end

    def apply_filter(scenarios, options, filter, value)
      case filter
      when 'search'
        scenarios.where('lower(name) LIKE ?', "%#{value.downcase}%")
      when 'order_type'
        fetch_with_order(
          scenarios,
          value,
          options['order_direction']
        )
      else
        scenarios
      end
    end

    def fetch_with_order(scenarios, order_type, order_direction)
      order_direction = get_order_direction(order_direction)
      order_type = get_order_type(ORDERS, order_type)

      if order_type == 'indicators'
        scenarios.time_series.
          order("count(indicator_id) #{order_direction}")
      elsif order_type == 'members'
        scenarios.time_series.
          order("count(scenario_id) #{order_direction}")
      else
        scenarios.order(order_type => order_direction, name: :asc)
      end
    end
  end
end
