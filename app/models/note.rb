class Note < ApplicationRecord
  belongs_to :model, required: true
  belongs_to :indicator, required: true

  validates :indicator_id, uniqueness: {scope: [:model_id]}
  validates :conversion_factor, presence: {
    message: "can't be blank if unit of entry differs from standard unit"
  }, if: :indicator_unit_of_entry_differs?

  private

  def indicator_unit_of_entry_differs?
    unit_of_entry.present? && unit_of_entry != indicator.try(:unit)
  end
end
