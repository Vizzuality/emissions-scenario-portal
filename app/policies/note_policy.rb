class NotePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.joins(:model).where(models: {team_id: user.team_id})
      end
    end
  end

  def create?
    true
  end

  def update?
    record.model.team_id == user.team_id || super
  end

  def destroy?
    record.model.team_id == user.team_id || super
  end
end
