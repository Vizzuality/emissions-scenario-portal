class Model < ApplicationRecord
  ALL_ATTRIBUTES = YAML.load_file(
    Rails.root.join('db', 'models_metadata.yml')
  ).freeze
  include MetadataAttributes

  belongs_to :team, optional: true
  has_many :scenarios, dependent: :destroy

  validates :abbreviation, presence: true, uniqueness: true
  validates :full_name, presence: true
  validates(
    :development_year,
    numericality: {only_integer: true, allow_nil: true},
    inclusion: {in: 1900..Date.today.year, allow_nil: true}
  )
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

  def self.team(team)
    where(team_id: [nil, team.respond_to?(:id) ? team.id : team].uniq)
  end

  def scenarios?
    scenarios.any?
  end

  class << self
    def have_time_series
      models_ids = TimeSeriesValue.joins(:scenario).
        select(:model_id).distinct

      where(id: models_ids.map(&:model_id))
    end

    def filtered_by_locations(location_ids)
      joins({indicators: {time_series_values: :location}}, :scenarios).
        where(indicators: {time_series_values: {location_id: location_ids}}).
        distinct
    end
  end
end
