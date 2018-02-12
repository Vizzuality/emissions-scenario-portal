class Scenario < ApplicationRecord
  ALL_ATTRIBUTES = YAML.load_file(
    Rails.root.join('db', 'scenarios_metadata.yml')
  ).freeze
  include MetadataAttributes

  belongs_to :model
  has_many :time_series_values, dependent: :destroy

  validates :name, presence: true
  validates :model, presence: true
  validates :published, inclusion: {in: [false, true]}
  before_validation :ignore_blank_array_values

  delegate :abbreviation, to: :model, prefix: :model

  scope :having_time_series, -> { where.not(time_series_values_count: 0) }

  def self.find_by_name(name)
    where('lower(name) = ?', name.to_s.downcase).first
  end

  def indicators
    Indicator.where(id: time_series_values.select(:indicator_id))
  end

  def time_series_data?
    time_series_values_count.positive?
  end
end
