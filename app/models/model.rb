class Model < ApplicationRecord
  include ModelAttributes

  belongs_to :team
  has_many :scenarios, dependent: :restrict_with_error
end
