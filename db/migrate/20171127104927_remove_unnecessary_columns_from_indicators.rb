class RemoveUnnecessaryColumnsFromIndicators < ActiveRecord::Migration[5.1]
  def change
    remove_column :indicators, :unit_of_entry, :text
    remove_column :indicators, :conversion_factor, :decimal
    remove_column :indicators, :parent_id, :integer
    remove_column :indicators, :model_id, :integer
    remove_column :indicators, :auto_generated, :boolean
  end
end
