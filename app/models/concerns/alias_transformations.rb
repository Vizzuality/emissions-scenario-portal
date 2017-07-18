require 'active_support/concern'

module AliasTransformations
  extend ActiveSupport::Concern

  included do
    # update alias if system indicator
    # or team indicator with blank alias
    before_save :update_alias, if: proc { |i|
      i.parent_id.blank? && (i.model_id.blank? || i.alias.blank?)
    }
  end

  def update_alias
    self.alias = [category, subcategory, name].join('|').chomp('|')
  end

  class_methods do
    def slug_to_hash(slug)
      return {} unless slug.present?
      slug_parts = slug && slug.split('|', 3)
      return {} if slug_parts.empty?
      slug_hash = {category: slug_parts[0].strip}
      if slug_parts.length >= 2
        slug_hash[:subcategory] = slug_parts[1].strip
        slug_hash[:name] = slug_parts[2].strip if slug_parts.length == 3
      end
      slug_hash
    end
  end
end
