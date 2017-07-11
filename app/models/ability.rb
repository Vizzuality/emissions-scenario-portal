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
      can :fork, Indicator
      can :read, Indicator do |indicator|
        team.id == indicator.team_id || indicator.parent_id.blank?
      end
      can :manage, Indicator do |indicator|
        team.id == indicator.team_id
      end
      can :download_time_series, Indicator
      can :show, Team, id: team.id
      can :edit, Team, id: team.id
      can :update, Team, id: team.id
      can :create, User do |user|
        user.team.nil? || user.team_id == team.id
      end
      can :destroy, User, team_id: team.id
    end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities
  end
end
