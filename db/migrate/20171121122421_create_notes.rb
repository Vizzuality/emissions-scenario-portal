class CreateNotes < ActiveRecord::Migration[5.1]
  def change
    create_table :notes do |t|
      t.text :description
      t.text :unit_of_entry
      t.decimal :conversion_factor
      t.belongs_to :indicator, foreign_key: true, null: false
      t.belongs_to :model, foreign_key: true, null: false

      t.timestamps
    end

    add_index :notes, [:indicator_id, :model_id], unique: true
  end
end
