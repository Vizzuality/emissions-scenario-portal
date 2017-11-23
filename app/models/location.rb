class Location < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :iso_code, length: {is: 2}, uniqueness: true, unless: :region?
  validates :region, inclusion: {in: [false, true]}

  before_validation :upcase_iso_code

  private

  def upcase_iso_code
    iso_code.upcase!
  end
end
