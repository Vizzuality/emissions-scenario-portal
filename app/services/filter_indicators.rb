class FilterIndicators
  ORDER_COLUMNS = %w[esp_name definition unit model_name added_by type].freeze

  include ActiveModel::Model

  attr_accessor :search, :order_type, :order_direction, :type, :category

  def call(scope)
    scope.
      merge(search_scope).
      merge(order_scope).
      merge(type_scope).
      merge(category_scope)
  end

  private

  def indicators
    Indicator.with_variations
  end

  def search_scope
    return indicators if search.blank?
    indicators.search_for(search)
  end

  def order_scope
    return indicators unless ORDER_COLUMNS.include?(order_type)
    direction = order_direction.to_s.casecmp('desc').zero? ? :desc : :asc
    order_clause = send("#{order_type}_order_clause", direction)
    indicators.order(order_clause)
  end

  def type_scope
    case type
    when 'system'
      indicators.
        where(model_id: nil).
        where('variations_models.id' => nil)
    when /team-(\d+)/
      indicators.
        where('models.team_id = :team_id', team_id: Regexp.last_match[1].to_i)
    else
      indicators
    end
  end

  def category_scope
    return indicators if category.blank?
    indicators.where('indicators.category IN (?)', category.split(','))
  end

  def model_name_order_clause(direction)
    sql = <<~END_OF_SQL
      CASE
        WHEN variations.alias IS NOT NULL THEN variations.alias
        WHEN indicators.model_id IS NOT NULL THEN indicators.alias
        ELSE NULL
      END
    END_OF_SQL
    [sql, direction].join(' ')
  end

  def esp_name_order_clause(direction)
    %w(category subcategory name).map do |column|
      ["indicators.#{column}", direction].join(' ')
    end.join(', ')
  end

  def added_by_order_clause(direction)
    sql = <<~END_OF_SQL
      CASE
        WHEN variations.id IS NOT NULL THEN variations_teams.name
        WHEN indicators.model_id IS NOT NULL THEN teams.name
        ELSE NULL
      END,
      CASE
        WHEN variations.id IS NOT NULL THEN variations.created_at
        WHEN indicators.model_id IS NOT NULL THEN indicators.created_at
        ELSE NULL
      END
    END_OF_SQL
    [sql, direction].join(' ')
  end

  def type_order_clause(direction)
    sql = 'indicators.parent_id IS NULL, indicators.model_id'
    [sql, direction].join(' ')
  end

  def definition_order_clause(direction)
    generic_order_clause(direction)
  end

  def unit_order_clause(direction)
    generic_order_clause(direction)
  end

  def generic_order_clause(direction)
    ["indicators.#{order_type}", direction].join(' ')
  end
end
