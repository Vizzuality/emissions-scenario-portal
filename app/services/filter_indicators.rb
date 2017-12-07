class FilterIndicators
  cattr_reader :order_columns do
    %w[esp_name definition unit].freeze
  end

  include ActiveModel::Model
  include OrderableFilter

  attr_accessor :search, :type, :category

  def call(scope)
    scope.
      merge(search_scope).
      merge(order_scope).
      merge(category_scope)
  end

  private

  def indicators
    Indicator.all
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

  def category_scope
    return indicators if category.blank?

    query = indicators.
      includes(:category, :subcategory).
      references(:category, :subcategory)

    ids = category.split(',').map(&:to_i)

    query.where('categories.id IN (?) OR subcategories_indicators.id IN (?)', ids, ids)
  end

  def esp_name_order_clause(direction)
    %w(categories.name subcategories_indicators.name indicators.name).map do |column|
      [column, direction].join(' ')
    end.join(', ')
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
