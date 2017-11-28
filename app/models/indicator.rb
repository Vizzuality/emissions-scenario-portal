class Indicator < ApplicationRecord
  ALL_ATTRIBUTES = YAML.load_file(
    Rails.root.join('db', 'indicators_metadata.yml')
  ).freeze
  include MetadataAttributes
  include PgSearch

  has_many :time_series_values, dependent: :destroy
  belongs_to :category
  belongs_to :subcategory, class_name: 'Category', optional: true

  validates :composite_name, uniqueness: true
  before_validation :ignore_blank_array_values
  before_validation :strip_whitespace
  before_validation :generate_composite_name

  pg_search_scope :search_for, against: %i[name composite_name]

  def self.slug_to_hash(slug)
    return {} unless slug.present?
    slug_parts = slug && slug.split('|', 3).map(&:strip)
    return {} if slug_parts.empty?
    slug_parts_to_hash(slug_parts)
  end

  def self.slug_parts_to_hash(slug_parts)
    slug_hash = {category: slug_parts[0]}
    if slug_parts.length >= 2
      slug_hash[:subcategory] = slug_parts[1].presence
      slug_hash[:name] = slug_parts[2].presence if slug_parts.length == 3
    end
    slug_hash
  end

  def self.hash_to_slug(hash)
    [hash[:category].name, hash[:subcategory].name, hash[:name]].join('|')
  end

  def self.best_effort_matches(indicator_name, model)
    Indicator.where('lower(composite_name) = ?', indicator_name.to_s.downcase)
  end

  def system?
    true
  end

  def fork_variation(attributes)
    self
  end

  def fork_system_indicator
    self
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

  private

  def strip_whitespace
    self.name = name.try(:strip)
    self.unit = unit.try(:strip)
  end

  def generate_composite_name
    self.composite_name ||= [category&.name, subcategory&.name, name].join('|').chomp('|')
  end
end
