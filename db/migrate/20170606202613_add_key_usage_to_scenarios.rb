class AddKeyUsageToScenarios < ActiveRecord::Migration[5.0]
  def change
    add_column :scenarios, :key_usage, :text
  end
end
