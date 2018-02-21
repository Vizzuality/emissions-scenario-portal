class Note < ApplicationRecord
  ALL_ATTRIBUTES = YAML.load_file(
    Rails.root.join('db', 'notes_metadata.yml')
  ).freeze
  include MetadataAttributes

  belongs_to :model
  belongs_to :indicator

  validates :indicator_id, uniqueness: {scope: [:model_id]}
  validates :unit_of_entry, presence: {if: :unit_of_entry_required?}
  validates :conversion_factor, numericality: {other_than: 0, allow_nil: true}

  before_validation :ignore_blank_array_values

  private

  def unit_of_entry_required?
    conversion_factor.present? && conversion_factor != 1
  end
end
