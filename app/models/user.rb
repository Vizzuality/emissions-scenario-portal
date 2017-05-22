class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :recoverable, :rememberable,
         :trackable, :validatable
  belongs_to :team, optional: true

  validates :team, presence: true, unless: :admin?
end
