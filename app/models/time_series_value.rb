class TimeSeriesValue < ApplicationRecord
  belongs_to :scenario
  belongs_to :indicator
  belongs_to :location

  validates(
    :year,
    presence: true,
    numericality: {only_integer: true, allow_nil: true},
    inclusion: {in: 1900..2100, allow_nil: true}
  )
  validates :value, presence: true, numericality: {allow_nil: true}
  validates :scenario, presence: true
  validates :indicator, presence: true
  validates :location, presence: true
  validate :unit_compatible_with_indicator, if: proc { |v| v.indicator }

  def unit_compatible_with_indicator
    if unit_of_entry.present? &&
        unit_of_entry != indicator.unit &&
        unit_of_entry != indicator.unit_of_entry
      errors[:unit_of_entry] << 'Unit of entry incompatible with indicator.'
    end
  end
end
