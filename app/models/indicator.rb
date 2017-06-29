class Indicator < ApplicationRecord
  ALL_ATTRIBUTES = YAML.load_file(
    Rails.root.join('db', 'indicators_metadata.yml')
  ).freeze
  include MetadataAttributes
  include PgSearch

  ORDERS = %w[alias name category subcategory definition unit].freeze

  belongs_to :parent, class_name: 'Indicator', optional: true
  has_many :time_series_values, dependent: :destroy
  belongs_to :model, optional: true

  validates :category, presence: true
  before_validation :ignore_blank_array_values
  before_save :update_alias, if: proc { |i| i.parent.blank? }

  pg_search_scope :search_for, against: [
    :category, :subcategory, :name, :alias
  ]

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

  def time_series_values_pivot
    pivot = TimeSeriesYearPivotQuery.new(time_series_values)
    result = TimeSeriesValue.find_by_sql(pivot.query)
    years = pivot.years
    data = result.map do |tsv|
      {
        scenario_name: tsv['scenario_name'],
        location_name: tsv['region'],
        unit_of_entry: tsv['unit_of_entry'],
        values: years.map { |y| tsv[y] }
      }
    end
    {
      years: years,
      data: data
    }
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
      indicators = Indicator
      options.each do |filter|
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
        indicators.search_for(value)
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
  end

  def time_series_data?
    time_series_values.any?
  end

  # TODO: validate comparable indicator has convertible unit
  # TODO: unit conversions
end
