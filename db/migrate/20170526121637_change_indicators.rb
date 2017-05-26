class ChangeIndicators < ActiveRecord::Migration[5.0]
  def change
    add_column :indicators, :subcategory, :text
    add_column :indicators, :stackable_subcategory, :boolean, default: false
    add_column :indicators, :unit_of_entry, :text
    add_column :indicators, :conversion_factor, :numeric
    add_reference :indicators, :parent, index: true, foreign_key: { to_table: :indicators }
  end
end
