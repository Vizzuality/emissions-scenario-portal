class CreateIndicators < ActiveRecord::Migration[5.0]
  def change
    create_table :indicators do |t|
      t.text :category
      t.text :stack_family
      t.text :name
      t.text :definition
      t.text :unit
      t.text :notes

      t.timestamps
    end
  end
end
