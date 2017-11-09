class Indicator < ApplicationRecord
  ALL_ATTRIBUTES = YAML.load_file(
    Rails.root.join('db', 'indicators_metadata.yml')
  ).freeze
  include MetadataAttributes
  include PgSearch
  include AliasTransformations
  include ScopeManagement
  include BestEffortMatching

  belongs_to :parent, class_name: 'Indicator', optional: true
  has_many :variations,
           class_name: 'Indicator', foreign_key: :parent_id,
           dependent: :nullify
  has_many :time_series_values, dependent: :destroy
  belongs_to :model, optional: true

  validates :model, presence: true, if: proc { |i| i.parent.present? }
  validates :conversion_factor, presence: {
    message: "can't be blank if unit of entry differs from standard unit"
  }, if: proc { |i| i.unit_of_entry.present? && i.unit_of_entry != unit }
  validate :unit_compatible_with_parent, if: proc { |i| i.parent.present? }
  validate :parent_is_not_variation, if: proc { |i| i.parent.present? }
  before_validation :ignore_blank_array_values

  pg_search_scope :search_for, against: [
    :category, :subcategory, :name, :alias
  ]

  def self.model_variations(model)
    where(model_id: model.respond_to?(:id) ? model.id : model)
  end

  def self.system_and_team
    where(parent_id: nil)
  end

  def self.system
    system_and_team.where(model_id: nil)
  end

  def self.with_variations
    joins('LEFT JOIN models ON models.id = indicators.model_id').
      joins('LEFT JOIN teams ON teams.id = models.team_id').
      eager_load(:variations).
      joins("LEFT JOIN indicators variations ON variations.parent_id = \
indicators.id").
      joins("LEFT JOIN models variations_models ON variations_models.id = \
variations.model_id").
      joins("LEFT JOIN teams variations_teams ON variations_teams.id = \
variations_models.team_id")
  end

  def self.for_scenario(scenario_id)
    subquery = TimeSeriesValue.where(scenario_id: scenario_id).
      select(:indicator_id).group(:indicator_id).to_sql
    with_variations.
      joins("JOIN (#{subquery}) s ON variations.id = s.indicator_id")
  end

  def unit_compatible_with_parent
    return true if unit.blank? && parent.unit.blank? || unit == parent.unit
    errors[:unit] << 'incompatible with parent indicator'
  end

  def parent_is_not_variation
    return true unless parent.variation?
    errors[:parent] << 'cannot be a variation'
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

  def time_series_data?
    time_series_values.any?
  end
end
