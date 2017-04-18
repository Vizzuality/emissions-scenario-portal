class AddMoreModelAttributes < ActiveRecord::Migration[5.0]
  def change
    add_column :models, :current_version, :text
    add_column :models, :linkages_and_extensions, :text
    add_column :models, :development_year, :integer
    add_column :models, :programming_language, :text, array: true, default: []
    add_column :models, :maintainer_type, :text
    add_column :models, :maintainer_name, :text
    add_column :models, :license, :text
    add_column :models, :license_detailed, :text
    add_column :models, :availability, :text
    add_column :models, :expertise, :text
    add_column :models, :expertise_detailed, :text
    add_column :models, :platform, :text, array: true, default: []
    add_column :models, :platform_detailed, :text
    add_column :models, :category, :text
    add_column :models, :category_detailed, :text
    add_column :models, :hybrid_classification, :text
    add_column :models, :hybrid_classification_detailed, :text
    add_column :models, :purpose_or_objective, :text
    add_column :models, :description, :text
    add_column :models, :key_usage, :text, array: true, default: []
    add_column :models, :scenario_coverage, :text
    add_column :models, :scenario_coverage_details, :text, array: true, default: []
    add_column :models, :geographic_coverage, :text
    add_column :models, :geographic_coverage_region, :text, array: true, default: []
    add_column :models, :geographic_coverage_country, :text, array: true, default: []
    add_column :models, :sectoral_coverage, :text, array: true, default: []
    add_column :models, :gas_and_pollutant_coverage, :text, array: true, default: []
    add_column :models, :policy_coverage, :text, array: true, default: []
    add_column :models, :technology_coverage, :text, array: true, default: []
    add_column :models, :technology_coverage_detailed, :text
    add_column :models, :energy_resource_coverage, :text, array: true, default: []
    add_column :models, :time_horizon, :text
    add_column :models, :time_step, :text
    add_column :models, :equilibrium_type, :text
    add_column :models, :foresight, :text
    add_column :models, :spatial_resolution, :text
    add_column :models, :population_assumptions, :text
    add_column :models, :gdp_assumptions, :text
    add_column :models, :other_assumptions, :text
    add_column :models, :base_year, :integer
    add_column :models, :input_data, :text
    add_column :models, :calibration_and_validation, :text
    add_column :models, :languages, :text, array: true, default: []
    add_column :models, :tutorial_and_training_opportunities, :text, array: true, default: []
    add_column :models, :system_requirements, :text
    add_column :models, :run_time, :text
    add_column :models, :publications_and_notable_projects, :text
    add_column :models, :citation, :text
    add_column :models, :url, :text
    add_column :models, :point_of_contact, :text
  end
end
