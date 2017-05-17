class Scenario < ApplicationRecord
  ALL_ATTRIBUTES = YAML.load_file(
    Rails.root.join('db', 'scenarios_metadata.yml')
  ).freeze
  include MetadataAttributes

  belongs_to :model
  has_many :time_series_values, dependent: :destroy
  has_many :indicators, through: :time_series_values

  def meta_data?
    # TODO: what to check here?
    true
  end

  def time_series_data?
    time_series_values.any?
  end
end
