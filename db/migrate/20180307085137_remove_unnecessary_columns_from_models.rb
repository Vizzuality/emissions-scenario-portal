class RemoveUnnecessaryColumnsFromModels < ActiveRecord::Migration[5.1]
  def change
    remove_column :models, :development_year, :integer
    remove_column :models, :availability, :text
    remove_column :models, :parent_model, :text
    remove_column :models, :descendent_models, :text
    remove_column :models, :expertise_detailed, :text
    remove_column :models, :purpose_or_objective, :text
    remove_column :models, :scenario_coverage_detailed, :text
    remove_column :models, :geographic_coverage_country, :text, default: [], array: true
    remove_column :models, :policy_coverage_detailed, :text
    remove_column :models, :technology_coverage_detailed, :text
    remove_column :models, :spatial_resolution, :text
    rename_column :models, :maintainer_name, :maintainer_institute
  end
end
