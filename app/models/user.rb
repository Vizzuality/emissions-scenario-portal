class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  belongs_to :team, optional: true

  validates :team, presence: true, unless: :admin?
  # TODO: format validation: to be decided when registration / auth style
  # determined
end
