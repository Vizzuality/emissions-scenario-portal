class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :recoverable, :rememberable,
         :trackable, :validatable
  belongs_to :team, optional: true

  validates :team, presence: true, unless: :admin?
  validates :team, team_reassignment: true

  delegate :can?, :cannot?, to: :ability

  def ability
    @ability ||= Ability.new(self)
  end
end
