class Note < ApplicationRecord
  belongs_to :model
  belongs_to :indicator

  validates :indicator_id, uniqueness: {scope: [:model_id]}
  validates :unit_of_entry, presence: true
  validates :conversion_factor, numericality: {other_than: 0}
end
