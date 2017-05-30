class Indicator < ApplicationRecord
  ALL_ATTRIBUTES = YAML.load_file(
    Rails.root.join('db', 'indicators_metadata.yml')
  ).freeze
  include MetadataAttributes

  ORDERS = %w[name category subcategory definition unit].freeze

  belongs_to :parent, class_name: 'Indicator'
  has_many :time_series_values, dependent: :destroy
  belongs_to :model, optional: true

  validates :name, presence: true
  before_validation :ignore_blank_array_values

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
      if ['category'].include? filter
        return fetch_equal_value(indicators, filter, value)
      end

      case filter
      when 'search'
        indicators.where('lower(name) LIKE ?', "%#{value.downcase}%")
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
      order_direction = get_order_direction(order_direction)
      order_type = get_order_type(ORDERS, order_type)

      indicators.order(order_type => order_direction, name: :asc)
    end

    def fetch_equal_value(indicators, filter, value)
      indicators.where("#{filter} IN (?)", value.split(','))
    end

    def find_all_by_slug(slug)
      slug_parts = slug.split('|')
      if slug_parts.length == 2
        category, name = slug_parts
      elsif slug_parts.length == 3
        category, subcategory, name = slug_parts
      end
      rel = where(category: category, name: name)
      rel = rel.where(subcategory: subcategory) if subcategory
      rel
    end
  end

  def time_series_data?
    time_series_values.any?
  end

  # TODO: validate comparable indicator has convertible unit
  # TODO: unit conversions
end
