class ChangeKeyUsageFromArrayToTextInModels < ActiveRecord::Migration[5.0]
  def change
    change_column :models, :key_usage, :text
  end
end
