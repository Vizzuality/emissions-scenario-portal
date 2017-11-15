class FilterIndicators
  cattr_reader :order_columns do
    %w[esp_name definition unit model_name added_by type].freeze
  end

  include ActiveModel::Model
  include OrderableFilter

  attr_accessor :search, :type, :category

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
    return indicators if order_type.blank?

    order_clause = send("#{order_type}_order_clause", order_direction)
    indicators.
      joins(:category, :subcategory).
      order(order_clause)
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

    indicators.
      includes(:category).
      references(:category).
      where('categories.name IN (?)', category.split(','))
  end

  def model_name_order_clause(direction)
    sql = <<~END_OF_SQL
      CASE
        WHEN indicators.model_id IS NOT NULL AND
             indicators.parent_id IS NOT NULL THEN indicators.alias
        ELSE ''
      END
    END_OF_SQL
    [sql, direction].join(' ')
  end

  def esp_name_order_clause(direction)
    %w(categories.name subcategories_indicators.name indicators.name).map do |column|
      [column, direction].join(' ')
    end.join(', ')
  end

  def added_by_order_clause(direction)
    sql = <<~END_OF_SQL
      CASE
        WHEN indicators.model_id IS NOT NULL THEN teams.name
        ELSE 'System'
      END,
      CASE
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
