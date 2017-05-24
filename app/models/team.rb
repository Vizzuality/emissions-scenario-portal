class Team < ApplicationRecord
  has_many :users, dependent: :restrict_with_error
  has_many :models, dependent: :nullify

  validates :name, presence: true, uniqueness: true
end
