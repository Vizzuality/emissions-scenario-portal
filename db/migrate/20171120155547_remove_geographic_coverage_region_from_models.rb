class RemoveGeographicCoverageRegionFromModels < ActiveRecord::Migration[5.1]
  def change
    remove_column :models, :geographic_coverage_region, :text, array: true
  end
end
