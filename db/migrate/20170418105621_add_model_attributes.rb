class AddModelAttributes < ActiveRecord::Migration[5.0]
  def change
    add_column :models, :abbreviation, :text
    add_column :models, :full_name, :text
    execute 'UPDATE models SET abbreviation = name, full_name = name'
    change_column :models, :abbreviation, :text, null: false
    add_index :models, :abbreviation, unique: true
    change_column :models, :full_name, :text, null: false
    remove_column :models, :name
  end
end
