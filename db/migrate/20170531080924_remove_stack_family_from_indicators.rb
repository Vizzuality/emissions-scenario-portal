class RemoveStackFamilyFromIndicators < ActiveRecord::Migration[5.0]
  def change
    remove_column :indicators, :stack_family
  end
end
