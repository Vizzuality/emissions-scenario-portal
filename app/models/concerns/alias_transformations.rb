require 'active_support/concern'

module AliasTransformations
  extend ActiveSupport::Concern

  included do
    # copy shared attributes from parent if variation
    before_validation :copy_from_parent, if: proc { |i|
      i.parent_id.present?
    }

    # ensure no trailing whitespace in attributes used for matching
    before_validation :strip_whitespace
    before_validation :fix_category_capitalisation, if: proc { |i|
      i.category.present?
    }

    # update alias if system indicator
    # or team indicator with blank alias
    before_save :update_alias, if: proc { |i|
      i.parent_id.blank? && (i.model_id.blank? || i.alias.blank?)
    }
    before_save :update_category, if: proc { |i| i.parent.present? }

    validates :category, presence: true, inclusion: {
      in: Indicator.valid_categories,
      message: 'must be one of ' +
        Indicator.valid_categories.join(', '),
      if: proc { |i| i.category.present? }
    }
  end

  def copy_from_parent
    self.category = parent.category
    self.subcategory = parent.subcategory
    self.name = parent.name
    self.stackable_subcategory = parent.stackable_subcategory
    self.unit = parent.unit
  end

  def strip_whitespace
    self.category = category.try(:strip)
    self.subcategory = subcategory.try(:strip)
    self.name = name.try(:strip)
    self.unit = unit.try(:strip)
    self.unit_of_entry = unit_of_entry.try(:strip)
  end

  def fix_category_capitalisation
    self.category = Indicator.fix_category_capitalisation(category)
  end

  def update_alias
    self.alias = build_alias
  end

  def build_alias
    [category, subcategory, name].join('|').chomp('|')
  end

  def update_category
    self.category = parent.category
    self.subcategory = parent.subcategory
    self.name = parent.name
    self.stackable_subcategory = parent.stackable_subcategory
  end

  class_methods do
    def slug_to_hash(slug)
      return {} unless slug.present?
      slug_parts = slug && slug.split('|', 3).map(&:strip)
      return {} if slug_parts.empty?
      slug_parts_to_hash(slug_parts)
    end

    def slug_parts_to_hash(slug_parts)
      slug_hash = {category: fix_category_capitalisation(slug_parts[0])}
      if slug_parts.length >= 2
        slug_hash[:subcategory] = slug_parts[1].presence
        slug_hash[:name] = slug_parts[2].presence if slug_parts.length == 3
      end
      slug_hash
    end

    def hash_to_slug(hash)
      [hash[:category], hash[:subcategory], hash[:name]].join('|')
    end

    def valid_categories
      Indicator.attribute_info(:category).options
    end

    def fix_category_capitalisation(category)
      idx = valid_categories.map(&:downcase).
        index(category.downcase)
      idx && valid_categories[idx] || category
    end
  end
end
