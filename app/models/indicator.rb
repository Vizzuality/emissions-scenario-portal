class Indicator < ApplicationRecord
  ALL_ATTRIBUTES = YAML.load_file(
    Rails.root.join('db', 'indicators_metadata.yml')
  ).freeze
  include MetadataAttributes
  include PgSearch
  include Sanitizer
  include AliasTransformations

  ORDERS = %w[alias name category subcategory definition unit type].freeze

  belongs_to :parent, class_name: 'Indicator', optional: true
  has_many :variations,
           class_name: 'Indicator', foreign_key: :parent_id,
           dependent: :nullify
  has_many :time_series_values, dependent: :destroy
  belongs_to :team, optional: true

  validates :category, presence: true
  validates :team, presence: true, if: proc { |i| i.parent.present? }
  validates :conversion_factor, presence: {
    message: "can't be blank if unit of entry differs from standard unit"
  }, if: proc { |i| i.unit_of_entry.present? && i.unit_of_entry != unit }
  validate :unit_compatible_with_parent, if: proc { |i| i.parent.present? }
  validate :parent_is_not_variation, if: proc { |i| i.parent.present? }
  before_validation :ignore_blank_array_values
  before_save :update_category, if: proc { |i| i.parent.present? }
  before_save :promote_parent_to_system_indicator, if: proc { |i|
    i.parent.present? && i.parent.team_id.present?
  }

  pg_search_scope :search_for, against: [
    :category, :subcategory, :name, :alias
  ]

  def scope
    if parent_id.blank? && team_id.blank?
      :system_indicator
    elsif parent_id.blank?
      :team_indicator
    else
      :team_variation
    end
  end

  def variation?
    scope == :team_variation
  end

  def unit_compatible_with_parent
    return true if unit.blank? && parent.unit.blank? || unit == parent.unit
    errors[:unit] << 'incompatible with parent indicator'
  end

  def parent_is_not_variation
    return true unless parent.variation?
    errors[:parent] << 'cannot be a variation'
  end

  def fork_variation(variation_attributes)
    indicator = dup
    indicator.parent = self
    indicator.attributes = variation_attributes
    indicator.auto_generated = true
    indicator
  end

  def fork_system_indicator
    system_indicator = dup
    system_indicator.team_id = nil
    system_indicator.parent_id = nil
    system_indicator.auto_generated = true
    system_indicator
  end

  def update_category
    self.category = parent.category
    self.subcategory = parent.subcategory
    self.name = parent.name
    self.stackable_subcategory = parent.stackable_subcategory
  end

  def promote_to_system_indicator
    system_indicator = fork_system_indicator
    new_parent = create_parent(system_indicator.attributes)
    new_parent.variations << self
    new_parent
  end

  def promote_parent_to_system_indicator
    system_indicator = parent.promote_to_system_indicator
    self.parent = system_indicator
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
    def for_team(team)
      team_indicators = Indicator.select(:id, :parent_id).
        where(team_id: team.id)
      Indicator.
        joins("LEFT JOIN (#{team_indicators.to_sql}) team_indicators \
ON indicators.id = team_indicators.parent_id").
        where(
          "team_id = ? OR team_id IS NULL AND team_indicators.id IS NULL OR \
team_id != ? AND indicators.parent_id IS NULL",
          team.id, team.id
        )
    end

    def fetch_all(options)
      indicators = Indicator.includes(:parent)
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

      order_type = 'parent_id' if order_type == 'type'
      indicators.order(order_type => order_direction, name: :asc)
    end

    def fetch_equal_value(indicators, filter, value)
      indicators.where("#{filter} IN (?)", value.split(','))
    end

    def fetch_by_type(indicators, value)
      return indicators if value.blank?
      return indicators.where('team_id IS NULL') if value == 'system'
      scope, team_id_str = value.split('-')
      team_id = sanitise_positive_integer(team_id_str)
      return indicators unless team_id.present?
      if scope == 'team'
        indicators.where(team_id: team_id)
      else
        indicators.
          where('team_id IS NOT NULL AND team_id != ?', team_id).
          where('indicators.parent_id IS NULL')
      end
    end
  end

  def time_series_data?
    time_series_values.any?
  end
end
