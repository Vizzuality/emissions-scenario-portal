class Model < ApplicationRecord
  ALL_ATTRIBUTES = YAML.load_file(
    Rails.root.join('db', 'models_metadata.yml')
  ).freeze
  include MetadataAttributes

  belongs_to :team, optional: true
  has_many :scenarios, dependent: :destroy
  has_many :notes, dependent: :destroy

  validates :abbreviation, presence: true, uniqueness: true
  validates :full_name, presence: true
  validates(
    :base_year,
    numericality: {only_integer: true, allow_nil: true},
    inclusion: {in: 1900..Date.today.year, allow_nil: true}
  )
  validates_format_of(
    :url,
    with: URI.regexp(%w(http https)),
    allow_blank: true
  )
  validates :team, team_reassignment: true
  before_validation :ignore_blank_array_values

  has_attached_file :logo, storage: :s3,
    path: "emissionspathways.org/#{Rails.env.production? ? 'www': 'staging'}.emissionspathways.org/#{Rails.env}/:class/:id/:filename",
    styles: {
      thumb: '300x300>'
    }

  validates_attachment_content_type :logo,
                                    content_type: ['image/jpeg', 'image/png']
  validates_attachment_size :logo, in: 0.kilobytes..2.megabytes

  def self.team(team)
    where(team_id: [nil, team.respond_to?(:id) ? team.id : team].uniq)
  end

  def scenarios?
    scenarios.any?
  end

  def indicators
    Indicator.
      distinct(:id).
      joins(time_series_values: :scenario).
      where(scenarios: {model_id: id})
  end

  def self.having_time_series
    distinct.joins(:scenarios).where.not(scenarios: {time_series_values_count: 0})
  end

  def self.having_published_scenarios
    distinct.joins(:scenarios).where(scenarios: {published: true})
  end

  def self.filtered_by_locations(location_ids)
    distinct.
      joins(scenarios: :time_series_values).
      where(scenarios: {time_series_values: {location_id: location_ids}})
  end

  def self.find_by_abbreviation(abbreviation)
    where('lower(abbreviation) = ?', abbreviation.to_s.downcase).first
  end
end
