class Category < ApplicationRecord
  belongs_to :parent, class_name: 'Category', foreign_key: 'parent_id',
             optional: true
  has_many :subcategories, class_name: 'Category', foreign_key: 'parent_id',
           dependent: :restrict_with_error
  has_many :indicators, dependent: :restrict_with_error

  accepts_nested_attributes_for :subcategories

  validates :name, presence: true
  validate :parent_categories_cannot_be_stackable,
           :cannot_have_subcategory_as_parent

  def subcategory?
    parent.present?
  end

  def parent_categories_cannot_be_stackable
    if stackable && !subcategory
      errors.add(:stackable, "can't be set on parent categories")
    end
  end

  def cannot_have_subcategory_as_parent
    errors.add(:parent, "can't be a subcategory") if parent.subcategory?
  end

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
end
