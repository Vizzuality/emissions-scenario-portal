class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.text :email
      t.text :name
      t.boolean :admin, default: false
      t.references :team, foreign_key: true

      t.timestamps
    end
  end
end
