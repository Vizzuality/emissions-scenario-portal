class MoveStackableFromCategoriesToIndicators < ActiveRecord::Migration[5.1]
  Category = Class.new(ApplicationRecord)
  Indicator = Class.new(ApplicationRecord)

  def change
    add_column :indicators, :stackable, :boolean, default: false
    Category.where(stackable: true).find_each do |category|
      not_stackable_category = Category.find_or_create_by(
        parent_id: category.parent_id,
        name: category.name,
        stackable: false
      )

      Indicator.where(subcategory_id: category.id).find_each do |indicator|
        indicator.update!(
          subcategory_id: not_stackable_category.id,
          stackable: true
        )
      end
    end
    Category.where(stackable: true).destroy_all
    remove_column :categories, :stackable, :boolean
  end
end
