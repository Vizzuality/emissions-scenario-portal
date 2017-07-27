class RemoveObsoleteScenarioFields < ActiveRecord::Migration[5.0]
  def change
    remove_column :scenarios, :model_version
    remove_column :scenarios, :release_date
    remove_column :scenarios, :provider_name
  end
end
