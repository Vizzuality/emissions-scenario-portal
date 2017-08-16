class ChangeScenarioCoverageFromSingleToMultipleInModels < ActiveRecord::Migration[5.0]
  def change
    add_column :models, :scenario_coverage_tmp, :text, array: true, default: []
    execute 'UPDATE models SET scenario_coverage_tmp = ARRAY[scenario_coverage]'
    remove_column :models, :scenario_coverage
    rename_column :models, :scenario_coverage_tmp, :scenario_coverage
  end
end
