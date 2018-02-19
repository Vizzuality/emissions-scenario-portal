class FilterCategories
  cattr_reader :order_columns do
    %w[name parent subcategories].freeze
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

  def categories
    Category.all
  end

  def search_scope
    return categories if search.blank?

    categories.where('lower(categories.name) LIKE :name', name: "%#{search.downcase}%")
  end

  def order_scope
    return categories if order_type.blank?

    if order_type == "subcategories"
      categories.
        select('categories.*, count(subcategories.id) AS subcategories_count').
        left_outer_joins(:subcategories).
        group('categories.id').
        order("subcategories_count #{order_direction}")
    else
      categories.order(order_type => order_direction, name: :asc)
    end
  end
end
