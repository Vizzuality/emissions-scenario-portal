class FilterTeams
  cattr_reader :order_columns do
    %w[name models members].freeze
  end

  include ActiveModel::Model
  include OrderableFilter

  attr_accessor :search

  def call(scope)
    scope.
      merge(search_scope).
      merge(order_scope)
  end

  private

  def teams
    Team.all
  end

  def search_scope
    return teams if search.blank?

    teams.where('lower(teams.name) LIKE ?', "%#{search.downcase}%")
  end

  def order_scope
    return teams if order_type.blank?

    case order_type
    when 'models'
      teams.models.order("count(team_id) #{order_direction}")
    when 'members'
      teams.users.order("count(team_id) #{order_direction}")
    else
      teams.order(order_type => order_direction, name: :asc)
    end
  end
end
