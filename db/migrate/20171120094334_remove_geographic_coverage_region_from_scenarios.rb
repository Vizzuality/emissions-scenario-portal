class RemoveGeographicCoverageRegionFromScenarios < ActiveRecord::Migration[5.1]
  def change
    remove_column :scenarios, :geographic_coverage_region, :text, array: true
  end
end
