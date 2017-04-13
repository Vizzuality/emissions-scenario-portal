class CreateScenarios < ActiveRecord::Migration[5.0]
  def change
    create_table :scenarios do |t|
      t.text :name
      t.references :model, foreign_key: true

      t.timestamps
    end
  end
end
