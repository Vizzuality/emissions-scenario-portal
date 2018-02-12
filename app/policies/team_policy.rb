class TeamPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.where(id: user.team_id)
      end
    end
  end

  def update?
    record.id == user.team_id || super
  end
end
