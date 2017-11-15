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

    # update alias if system indicator
    # or team indicator with blank alias
    before_save :update_alias, if: proc { |i|
      i.parent_id.blank? && (i.model_id.blank? || i.alias.blank?)
    }
    before_save :update_category, if: proc { |i| i.parent.present? }
  end

  def copy_from_parent
    self.category = parent.category
    self.subcategory = parent.subcategory
    self.name = parent.name
    self.stackable_subcategory = parent.stackable_subcategory
    self.unit = parent.unit
  end

  def strip_whitespace
    self.name = name.try(:strip)
    self.unit = unit.try(:strip)
    self.unit_of_entry = unit_of_entry.try(:strip)
  end

  def update_alias
    self.alias = build_alias
  end

  def build_alias
    [category.name, subcategory&.name, name].join('|').chomp('|')
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
      slug_hash = {category: slug_parts[0]}
      if slug_parts.length >= 2
        slug_hash[:subcategory] = slug_parts[1].presence
        slug_hash[:name] = slug_parts[2].presence if slug_parts.length == 3
      end
      slug_hash
    end

    def hash_to_slug(hash)
      [hash[:category].name, hash[:subcategory].name, hash[:name]].join('|')
    end
  end
end
