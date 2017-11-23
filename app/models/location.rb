class Location < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :iso_code, length: {is: 2}, uniqueness: true, unless: :region?
  validates :region, inclusion: {in: [false, true]}
end
