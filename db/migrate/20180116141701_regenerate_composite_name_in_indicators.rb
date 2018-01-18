class RegenerateCompositeNameInIndicators < ActiveRecord::Migration[5.1]
  class Indicator < ApplicationRecord; end
  class Category < ApplicationRecord; end

  def change
    Indicator.find_each do |indicator|
      name =
        indicator.name.presence ||
        "Indicator ##{indicator.id}"
      subcategory = Category.find(indicator.subcategory_id)
      category = Category.find(subcategory.parent_id)
      composite_name = [category.name, subcategory.name, name].join('|')

      if Indicator.
           where.not(id: indicator.id).
           where(composite_name: composite_name).
           exists?

        name = indicator.composite_name.split('|', 3).third
        composite_name = [category.name, subcategory.name, name].join('|')
      end

      indicator.update!(
        name: name,
        composite_name: composite_name
      )
    end
  end
end
