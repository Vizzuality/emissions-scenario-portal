class Note < ApplicationRecord
  belongs_to :model, required: true
  belongs_to :indicator, required: true

  validates :indicator_id, uniqueness: {scope: [:model_id]}
  validates(
    :unit_of_entry,
    presence: {
      message: "can't be blank if no description given",
      unless: :description?
    },
    exclusion: {
      in: ->(note) { [note.indicator.try(:unit)].compact },
      message: "can't be equal to indicator's unit"
    }
  )
  validates(
    :conversion_factor,
    presence: {
      message: "can't be blank if unit of entry present",
      if: :unit_of_entry?
    },
    absence: {
      message: "can't be present if unit of entry blank",
      unless: :unit_of_entry?
    },
    numericality: {
      other_than: 0,
      allow_nil: true
    }
  )
end
