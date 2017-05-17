class CreateLocations < ActiveRecord::Migration[5.0]
  def change
    create_table :locations do |t|
      t.text :name, null: false
      t.column :iso_code2, "char(2)"
      t.boolean :region, default: false

      t.timestamps
    end
  end
end
