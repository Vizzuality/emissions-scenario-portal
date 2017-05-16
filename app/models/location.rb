class Location < ApplicationRecord
  validates :name, presence: true
  validates :iso_code2, presence: true, unless: :region?
end
