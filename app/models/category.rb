class Category < ApplicationRecord
  validates :name, presence: true

  belongs_to :parent, class_name: 'Category', foreign_key: 'parent_id', optional: true
  has_many :subcategories, class_name: 'Category', foreign_key: 'parent_id'

  accepts_nested_attributes_for :subcategories

  ORDERS = %w[name parent stackable].freeze

  def self.case_insensitive_find_or_create(attributes)
    category = Category.where('lower(name) = lower(?)', attributes[:name])

    if attributes[:parent]
      category = category.where(parent: attributes[:parent])
    end

    if attributes[:stackable]
      category = category.where(stackable: attributes[:stackable])
    end

    category = category.first

    unless category
      category = Category.new(attributes)
    end

    category
  end

  class << self
    def fetch_all(options)
      categories = Category.includes(:subcategories).where(parent_id: nil)
      options.each do |filter|
        categories = apply_filter(categories, options, filter[0], filter[1])
      end
      unless options['order_type'].present?
        categories = categories.order(name: :asc)
      end
      categories
    end

    def apply_filter(categories, options, filter, value)
      puts "a_f #{filter} #{value}"
      case filter
      when 'search'
        categories.where(
          'lower(name) LIKE :name',
          name: "%#{value.downcase}%"
        )
      when 'order_type'
        fetch_with_order(
          categories,
          value,
          options['order_direction']
        )
      else
        categories
      end
    end

    def fetch_with_order(categories, order_type, order_direction)
      order_direction = get_order_direction(order_direction)
      order_type = get_order_type(ORDERS, order_type)

      categories.order(order_type => order_direction, name: :asc)
    end
  end
end
