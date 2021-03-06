class Indicator < ApplicationRecord
  ALL_ATTRIBUTES = YAML.load_file(
    Rails.root.join('db', 'indicators_metadata.yml')
  ).freeze
  include MetadataAttributes
  include PgSearch

  has_many :time_series_values, dependent: :destroy
  has_many :notes, dependent: :destroy
  belongs_to :subcategory, class_name: 'Category'

  validate :subcategory_has_parent, if: :subcategory_id?
  validates :name, uniqueness: {scope: :subcategory_id}

  before_validation :ignore_blank_array_values, :strip_whitespace
  before_save :generate_composite_name

  pg_search_scope :search_for, against: %i[name composite_name]

  scope :having_time_series, -> { where.not(time_series_values_count: 0) }
  scope :stackable, -> { where(stackable: true) }
  scope :non_stackable, -> { where(stackable: false) }

  def self.having_time_series_with(conditions)
    where(id: TimeSeriesValue.select(:indicator_id).where(conditions))
  end

  def self.find_by_name(name)
    where('lower(composite_name) = ?', name.to_s.downcase).first
  end

  def category
    subcategory&.parent
  end

  def category_id
    category&.id
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
    time_series_values_count > 0
  end

  private

  def subcategory_has_parent
    errors.add(:subcategory, :invalid) unless subcategory.subcategory?
  end

  def strip_whitespace
    self.name = name.gsub(/\s+/, ' ').strip if name.present?
    self.unit = unit.gsub(/\s+/, ' ').strip if unit.present?
  end

  def generate_composite_name
    self.composite_name = [category&.name, subcategory&.name, name].join('|').chomp('|')
  end
end
