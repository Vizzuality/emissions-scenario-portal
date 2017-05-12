class Indicator < ApplicationRecord
  ALL_ATTRIBUTES = YAML.load_file(
    Rails.root.join('db', 'indicators_metadata.yml')
  ).freeze
  include MetadataAttributes

  validates :name, presence: true

  # TODO: validate comparable indicator has convertible unit
  # TODO: unit conversions
end
