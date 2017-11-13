class CreateCategories < ActiveRecord::Migration[5.1]
  def change
    create_table :categories do |t|
      t.text :name
      t.references :parent, foreign_key: {
        to_table: :categories,
        on_delete: :cascade
      }
    end
  end
end
