class Location < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :region, inclusion: {in: [false, true]}
  validates(
    :iso_code,
    format: {with: /\A[A-Z]{2}\z/},
    uniqueness: true,
    unless: :region?
  )
end
