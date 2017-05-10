class User < ApplicationRecord
  belongs_to :team, optional: true

  validates :email, presence: true, uniqueness: true
  validates :team, presence: true, unless: :admin?
  # TODO: format validation: to be decided when registration / auth style
  # determined
end
