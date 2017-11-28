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

  def scenarios?
    scenarios.any?
  end
end
