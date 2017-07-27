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
    esp_name definition unit model_name
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
        fetch_equal_value(indicators, 'indicators.category', value)
      else
        indicators
      end
    end

    def fetch_with_order(indicators, order_type, order_direction)
      order_direction = get_order_direction(order_direction)
      order_type = get_order_type(ORDERS, order_type)
      order_clause =
        if order_type == 'model_name'
          model_name_order_clause(order_direction)
        elsif order_type == 'esp_name'
          esp_name_order_clause(order_direction)
        else
          ['indicators.' + order_type, order_direction].join(' ')
        end
      indicators.order(order_clause)
    end

    def model_name_order_clause(order_direction)
      sql = <<~SQL
        CASE
          WHEN variations_indicators.alias IS NOT NULL THEN variations_indicators.alias
          WHEN indicators.model_id IS NOT NULL THEN indicators.alias
          ELSE NULL
        END
        SQL
      [sql, order_direction].join(' ')
    end

    def esp_name_order_clause(order_direction)
      [
        'indicators.category', 'indicators.subcategory', 'indicators.name'
      ].map { |col| [col, order_direction].join(' ') }.join(', ')
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
