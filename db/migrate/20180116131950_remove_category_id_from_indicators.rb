class RemoveCategoryIdFromIndicators < ActiveRecord::Migration[5.1]
  def change
    remove_column :indicators, :category_id, :bigint
  end
end
