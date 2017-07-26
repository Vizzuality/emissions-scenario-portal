class Indicator < ApplicationRecord
  ALL_ATTRIBUTES = YAML.load_file(
    Rails.root.join('db', 'indicators_metadata.yml')
  ).freeze
  include MetadataAttributes
  include PgSearch
  include Sanitizer
  include AliasTransformations
  include ScopeManagement
  include BestEffortMatching

  ORDERS = %w[
    alias definition unit variation_name
  ].freeze

  belongs_to :parent, class_name: 'Indicator', optional: true
  has_many :variations,
           class_name: 'Indicator', foreign_key: :parent_id,
           dependent: :nullify
  has_many :time_series_values, dependent: :destroy
  belongs_to :model, optional: true

  validates :category, presence: true, inclusion: {
    in: Indicator.attribute_info(:category).options,
    message: 'must be one of ' +
      Indicator.attribute_info(:category).options.join(', '),
    if: proc { |i| i.category.present? }
  }
  validates :model, presence: true, if: proc { |i| i.parent.present? }
  validates :conversion_factor, presence: {
    message: "can't be blank if unit of entry differs from standard unit"
  }, if: proc { |i| i.unit_of_entry.present? && i.unit_of_entry != unit }
  validate :unit_compatible_with_parent, if: proc { |i| i.parent.present? }
  validate :parent_is_not_variation, if: proc { |i| i.parent.present? }
  before_validation :ignore_blank_array_values
  before_save :update_category, if: proc { |i| i.parent.present? }

  scope :system_indicators_with_variations, lambda {
    where(parent_id: nil).eager_load(:variations)
  }
  pg_search_scope :search_for, against: [
    :category, :subcategory, :name, :alias
  ]

  def unit_compatible_with_parent
    return true if unit.blank? && parent.unit.blank? || unit == parent.unit
    errors[:unit] << 'incompatible with parent indicator'
  end

  def parent_is_not_variation
    return true unless parent.variation?
    errors[:parent] << 'cannot be a variation'
  end

  def update_category
    self.category = parent.category
    self.subcategory = parent.subcategory
    self.name = parent.name
    self.stackable_subcategory = parent.stackable_subcategory
  end

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
      indicators = Indicator.all
      options.each do |filter, value|
        indicators = apply_filter(indicators, options, filter, value)
      end
      unless options['order_type'].present?
        indicators = indicators.order(name: :asc)
      end
      indicators
    end

    def apply_filter(indicators, options, filter, value)
      case filter
      when 'search'
        indicators.search_for(value)
      when 'order_type'
        fetch_with_order(
          indicators, value, options['order_direction']
        )
      when 'type'
        fetch_by_type(indicators, value)
      when 'category'
        fetch_equal_value(indicators, filter, value)
      else
        indicators
      end
    end

    def fetch_with_order(indicators, order_type, order_direction)
      order_direction = get_order_direction(order_direction)
      order_type = get_order_type(ORDERS, order_type)
      if order_type == 'variation_name'
        order_type = 'variations_indicators.alias'
      end
      indicators.order("#{order_type} #{order_direction}", name: :asc)
    end

    def fetch_equal_value(indicators, filter, value)
      indicators.where("#{filter} IN (?)", value.split(','))
    end

    def fetch_by_type(indicators, value)
      return indicators if value.blank?
      return indicators.where(model_id: nil) if value == 'system'
      scope, team_id_str = value.split('-')
      team_id = sanitise_positive_integer(team_id_str)
      return indicators unless team_id.present?
      if scope == 'team'
        indicators.joins(:model).where('models.team_id' => team_id)
      else
        indicators.joins(:model).
          where('models.team_id IS NOT NULL AND models.team_id != ?', team_id).
          where('indicators.parent_id IS NULL')
      end
    end
  end

  def time_series_data?
    time_series_values.any?
  end
end
