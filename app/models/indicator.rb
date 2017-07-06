class Indicator < ApplicationRecord
  ALL_ATTRIBUTES = YAML.load_file(
    Rails.root.join('db', 'indicators_metadata.yml')
  ).freeze
  include MetadataAttributes
  include PgSearch

  ORDERS = %w[alias name category subcategory definition unit type].freeze

  belongs_to :parent, class_name: 'Indicator', optional: true
  has_many :time_series_values, dependent: :destroy
  belongs_to :model, optional: true

  validates :category, presence: true
  before_validation :ignore_blank_array_values
  before_save :update_alias, if: proc { |i| i.parent.blank? }

  pg_search_scope :search_for, against: [
    :category, :subcategory, :name, :alias
  ]

  def scope
    if parent_id.blank? && model_id.blank? # TODO: link with team?
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

  def update_alias
    self.alias = [category, subcategory, name].join('|')
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
    def for_model(model)
      model_indicators = Indicator.select(:id, :parent_id).
        where(model_id: model.id)
      Indicator.
        joins("LEFT JOIN (#{model_indicators.to_sql}) model_indicators \
ON indicators.id = model_indicators.parent_id").
        where(
          'model_id = ? OR model_id IS NULL AND model_indicators.id IS NULL',
          model.id
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
      return indicators.where('model_id IS NULL') if value == 'core'
      team_id = sanitise_positive_integer(value.split('-').last)
      if team_id.present?
        indicators.joins(:model).where('models.team_id' => team_id)
      else
        indicators
      end
    end

    def slug_to_hash(slug)
      return {} unless slug.present?
      slug_parts = slug && slug.split('|')
      return {} if slug_parts.empty?
      slug_hash = {category: slug_parts[0].strip}
      if slug_parts.length >= 2
        slug_hash[:subcategory] = slug_parts[1].strip
        slug_hash[:name] = slug_parts[2].strip if slug_parts.length == 3
      end
      slug_hash
    end

    def sanitise_positive_integer(i, default = nil)
      new_i =
        if i.is_a?(String)
          tmp = i.to_i
          tmp.to_s == i ? tmp : nil
        else
          i
        end
      new_i && new_i.positive? ? new_i : default
    end
  end

  def time_series_data?
    time_series_values.any?
  end
end
