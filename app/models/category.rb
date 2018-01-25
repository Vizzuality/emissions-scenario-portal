class Category < ApplicationRecord
  belongs_to(
    :parent,
    class_name: 'Category',
    foreign_key: 'parent_id',
    optional: true
  )

  has_many(
    :subcategories,
    -> { order(:name) },
    class_name: 'Category',
    foreign_key: 'parent_id',
    dependent: :restrict_with_error
  )

  has_many(
    :indicators,
    class_name: 'Indicator',
    foreign_key: 'subcategory_id',
    dependent: :restrict_with_error
  )

  accepts_nested_attributes_for :subcategories

  validates :name, presence: true, uniqueness: {scope: %i[parent_id stackable]}
  validate :parent_categories_cannot_be_stackable,
           :cannot_have_subcategory_as_parent

  scope :parent_categories, -> { where(parent_id: nil) }
  scope :subcategories, -> { where.not(parent_id: nil) }

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

  def subcategory?
    parent.present?
  end

  def parent_categories_cannot_be_stackable
    if stackable && !subcategory?
      errors.add(:stackable, "can't be set on parent categories")
    end
  end

  def cannot_have_subcategory_as_parent
    if parent && parent.subcategory?
      errors.add(:parent, "can't be a subcategory")
    end
  end
end
