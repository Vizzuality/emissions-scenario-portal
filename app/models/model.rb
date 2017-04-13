class Model < ApplicationRecord
  belongs_to :team
  has_many :scenarios, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true
end
