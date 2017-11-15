class Category < ApplicationRecord
  belongs_to :parent, class_name: 'Category', foreign_key: 'parent_id', optional: true
  has_many :children, class_name: 'Category', foreign_key: 'parent_id'

  def self.case_insensitive_find_or_create(attributes)
    category = Category.where('lower(name) = lower(?)', attributes[:name])

    if (attributes[:parent])
      category = category.where(parent: attributes[:parent])
    end

    category = category.first

    unless category
      category = Category.new(attributes)
    end

    category
  end
end
