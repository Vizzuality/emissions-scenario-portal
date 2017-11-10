class FilterTeams
  ORDER_COLUMNS = %w[name models members].freeze

  include ActiveModel::Model

  attr_writer :order_type, :order_direction
  attr_accessor :search

  def call(scope)
    scope.
      merge(search_scope).
      merge(order_scope)
  end

  def order_type
    @order_type if ORDER_COLUMNS.include?(@order_type)
  end

  def order_direction
    @order_direction.to_s.casecmp('desc').zero? ? :desc : :asc
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
