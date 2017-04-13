class CreateModels < ActiveRecord::Migration[5.0]
  def change
    create_table :models do |t|
      t.text :name
      t.references :team, foreign_key: true

      t.timestamps
    end
  end
end
