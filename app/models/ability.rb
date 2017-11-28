class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    user ||= User.new # guest user (not logged in)
    team = user.team
    if user.admin?
      can :manage, :all
    else
      can :manage, Model, team_id: team.id
      can :manage, Scenario, model: {team_id: team.id}
      can :download_time_series, Scenario
      can :read, Indicator
      can :download_time_series, Indicator
      can :show, Team, id: team.id
      can :edit, Team, id: team.id
      can :update, Team, id: team.id
      can :create, User do |user|
        user.team.nil? || user.team_id == team.id
      end
      can :destroy, User, team_id: team.id
      can :read, Location
    end
  end
end
