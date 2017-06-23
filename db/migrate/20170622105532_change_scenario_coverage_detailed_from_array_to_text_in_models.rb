class ChangeScenarioCoverageDetailedFromArrayToTextInModels < ActiveRecord::Migration[5.0]
  def change
    rename_column :models, :scenario_coverage_details, :scenario_coverage_detailed
    change_column :models, :scenario_coverage_detailed, :text
  end
end
