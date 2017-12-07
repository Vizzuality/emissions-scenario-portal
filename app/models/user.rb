class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :recoverable, :rememberable,
         :trackable, :validatable
  belongs_to :team, optional: true
  has_many :csv_uploads

  validates :team, presence: true, unless: :admin?
  validates :team, team_reassignment: true
end
