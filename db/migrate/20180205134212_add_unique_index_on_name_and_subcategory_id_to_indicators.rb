class AddUniqueIndexOnNameAndSubcategoryIdToIndicators < ActiveRecord::Migration[5.1]
  def change
    add_index :indicators, [:subcategory_id, :name], unique: true
  end
end
