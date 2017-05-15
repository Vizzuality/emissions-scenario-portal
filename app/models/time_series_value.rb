class TimeSeriesValue < ApplicationRecord
  belongs_to :scenario
  belongs_to :indicator

  validates :year,
    presence: true,
    numericality: {only_integer: true, allow_nil: true},
    inclusion: {in: 1900..Date.today.year, allow_nil: true}
  validates :value, presence: true, numericality: {allow_nil: true}
end
