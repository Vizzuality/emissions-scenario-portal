class Indicator < ApplicationRecord
  ALL_ATTRIBUTES = YAML.load_file(
    Rails.root.join('db', 'indicators_metadata.yml')
  ).freeze
  include MetadataAttributes
  include PgSearch

  has_many :time_series_values, dependent: :destroy
  belongs_to :category
  belongs_to :subcategory, class_name: 'Category'

  validates :composite_name, uniqueness: true
  before_validation(
    :ignore_blank_array_values,
    :strip_whitespace,
    :generate_composite_name
  )

  pg_search_scope :search_for, against: %i[name composite_name]

  scope :having_time_series, -> { where.not(time_series_values_count: 0) }

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
    time_series_values_count > 0
  end

  private

  def strip_whitespace
    self.name = name.try(:strip)
    self.unit = unit.try(:strip)
  end

  def generate_composite_name
    self.composite_name ||= [category&.name, subcategory&.name, name].join('|').chomp('|')
  end
end
