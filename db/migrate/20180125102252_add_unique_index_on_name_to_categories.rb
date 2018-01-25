class AddUniqueIndexOnNameToCategories < ActiveRecord::Migration[5.1]
  def change
    add_index :categories, %i[name parent_id stackable], unique: true
  end
end
