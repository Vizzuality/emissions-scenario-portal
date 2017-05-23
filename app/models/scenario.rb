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
      search = options['search'] if options['search'].present?
      if options['order_type'].present?
        order_direction = if options['order_direction'].present?
                            get_direction(options['order_direction'])
                          else
                            :asc
                          end

        order_type = get_type(options['order_type'])
      end

      scenarios = Scenario
      scenarios = scenarios.where("name LIKE '%#{search}%'") if search.present?
      scenarios = fetch_with_order(scenarios, order_type, order_direction) if order_type.present?
      scenarios = Scenario.order(name: :asc) if not(order_type.present?)
      scenarios
    end

    def fetch_with_order(scenarios, order_type, order_direction)
      if order_type == 'indicators'
        scenarios.time_series.
          order("count(indicator_id) #{order_direction}")
      elsif order_type == 'time_series'
        scenarios.time_series.
          order("count(scenario_id) #{order_direction}")
      else
        scenarios.order(order_type => order_direction, name: :asc)
      end
    end

    def get_type(order_type)
      ORDERS.include?(order_type) && order_type
    end

    def get_direction(direction)
      direction == 'desc' ? :desc : :asc
    end
  end
end
