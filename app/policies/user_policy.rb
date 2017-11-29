class UserPolicy < ApplicationPolicy
  def update?
    record.id == user.id || super
  end
end
