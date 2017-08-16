class AddClimateTargetColumnsToScenarios < ActiveRecord::Migration[5.0]
  def change
    rename_column :scenarios, :climate_target, :climate_target_type
    add_column :scenarios, :climate_target_detailed, :text
    add_column :scenarios, :climate_target_date, :text
  end
end
