class Location < ApplicationRecord
  validates :name, presence: true
  validates :iso_code, presence: true, length: {maximum: 2}, unless: :region?
end
