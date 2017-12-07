class Location < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :region, inclusion: {in: [false, true]}
  validates(
    :iso_code,
    format: {with: /\A[A-Z]{2}\z/},
    uniqueness: true,
    unless: :region?
  )

  has_many :time_series_values

  def self.having_time_series
    distinct.joins(:time_series_values)
  end
end
