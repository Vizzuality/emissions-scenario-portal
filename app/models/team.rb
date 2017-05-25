class Team < ApplicationRecord
  has_many :users, dependent: :restrict_with_error
  has_many :models, dependent: :nullify

  validates :name, presence: true, uniqueness: true

  scope :models, (lambda do
    joins('LEFT JOIN "models"
      ON "models"."team_id" = "teams"."id"').
      group('teams.id')
  end)

  scope :users, (lambda do
    joins('LEFT JOIN "users"
      ON "users"."team_id" = "teams"."id"').
      group('teams.id')
  end)

  ORDERS = %w[name models members].freeze

  class << self
    def fetch_all(options)
      teams = Team
      options.each_with_index do |filter|
        teams = apply_filter(teams, options, filter[0], filter[1])
      end
      teams = teams.order(name: :asc) unless options['order_type'].present?
      teams
    end

    def apply_filter(teams, options, filter, value)
      case filter
      when 'search'
        teams.where('lower(teams.name) LIKE ?', "%#{value.downcase}%")
      when 'order_type'
        fetch_with_order(
          teams,
          value,
          options['order_direction']
        )
      else
        teams
      end
    end

    def fetch_with_order(teams, order_type, order_direction)
      order_direction = get_order_direction(order_direction)
      order_type = get_order_type(ORDERS, order_type)

      if order_type == 'models'
        teams.models.
          order("count(team_id) #{order_direction}")
      elsif order_type == 'members'
        teams.users.
          order("count(team_id) #{order_direction}")
      else
        teams.order(order_type => order_direction, name: :asc)
      end
    end
  end
end
