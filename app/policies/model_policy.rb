class ModelPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.where(team_id: user.team_id)
      end
    end
  end

  def create?
    true
  end

  def update?
    record.team_id == user.team_id || super
  end

  def destroy?
    record.team_id == user.team_id || super
  end
end
