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

  validates :name, presence: true, uniqueness: {scope: :parent_id}
  validate :cannot_have_subcategory_as_parent

  scope :top_level, -> { where(parent_id: nil) }
  scope :second_level, -> { where.not(parent_id: nil) }

  def self.find_by_name(name)
    sanitized_name = name.to_s.downcase.gsub(/\s+/, ' ').strip

    Category.where('lower(name) = ?', sanitized_name).first
  end

  def self.case_insensitive_find_or_create(attributes)
    category = Category.where('lower(name) = lower(?)', attributes[:name])

    if attributes[:parent]
      category = category.where(parent: attributes[:parent])
    end

    category = category.first

    unless category
      category = Category.new(attributes)
    end

    category
  end

  def self.top_level_having_time_series_with(conditions)
    where(
      id: Category.unscoped.where(
        id: Indicator.where(
          id: TimeSeriesValue.where(conditions).select(:indicator_id)
        ).select(:subcategory_id)
      ).select(:parent_id)
    )
  end

  def self.second_level_having_time_series_with(conditions)
    where(
      id: Indicator.where(
        id: TimeSeriesValue.where(conditions).select(:indicator_id)
      ).select(:subcategory_id)
    )
  end

  def subcategory?
    parent.present?
  end

  def cannot_have_subcategory_as_parent
    if parent && parent.subcategory?
      errors.add(:parent, "can't be a subcategory")
    end
  end
end
