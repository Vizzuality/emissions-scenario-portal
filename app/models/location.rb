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

  def self.find_by_name_or_iso_code(name)
    where('lower(name) = ?', name.to_s.downcase).
      or(where('lower(iso_code) = ?', name.to_s.downcase)).
      first
  end

  def self.having_time_series
    distinct.joins(:time_series_values)
  end
end
