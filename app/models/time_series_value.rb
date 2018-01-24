class TimeSeriesValue < ApplicationRecord
  belongs_to :scenario, counter_cache: true
  belongs_to :indicator, counter_cache: true
  belongs_to :location

  validates(
    :year,
    presence: true,
    numericality: {only_integer: true, allow_nil: true},
    inclusion: {in: 1900..3000, allow_nil: true}
  )
  validates :value, presence: true, numericality: {allow_nil: true}

  def note
    Note.find_by(model_id: scenario.model_id, indicator_id: indicator.id)
  end
end
