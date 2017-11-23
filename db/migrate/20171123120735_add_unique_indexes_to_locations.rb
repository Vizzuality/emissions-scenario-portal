class AddUniqueIndexesToLocations < ActiveRecord::Migration[5.1]
  def change
    add_index :locations, :name, unique: true
    add_index :locations, :iso_code, unique: true
  end
end
