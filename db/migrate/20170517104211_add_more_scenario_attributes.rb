class AddMoreScenarioAttributes < ActiveRecord::Migration[5.0]
  def change
    add_column :scenarios, :model_abbreviation, :text
    add_column :scenarios, :model_version, :text
    add_column :scenarios, :provider_type, :text
    add_column :scenarios, :provider_name, :text
    add_column :scenarios, :release_date, :date
    add_column :scenarios, :category, :text
    add_column :scenarios, :description, :text
    add_column :scenarios, :geographic_coverage_region, :text, array: true, default: []
    add_column :scenarios, :geographic_coverage_country, :text, array: true, default: []
    add_column :scenarios, :sectoral_coverage, :text, array: true, default: []
    add_column :scenarios, :gas_and_pollutant_coverage, :text, array: true, default: []
    add_column :scenarios, :policy_coverage, :text, array: true, default: []
    add_column :scenarios, :policy_coverage_detailed, :text
    add_column :scenarios, :technology_coverage, :text, array: true, default: []
    add_column :scenarios, :technology_coverage_detailed, :text
    add_column :scenarios, :energy_resource_coverage, :text, array: true, default: []
    add_column :scenarios, :time_horizon, :text
    add_column :scenarios, :time_step, :text
    add_column :scenarios, :climate_target, :text
    add_column :scenarios, :emissions_target, :text
    add_column :scenarios, :large_scale_bioccs, :text
    add_column :scenarios, :technology_assumptions, :text
    add_column :scenarios, :gdp_assumptions, :text
    add_column :scenarios, :population_assumptions, :text
    add_column :scenarios, :discount_rates, :text, array: true, default: []
    add_column :scenarios, :emission_factors, :text
    add_column :scenarios, :global_warming_potentials, :text
    add_column :scenarios, :policy_cut_off_year_for_baseline, :text
    add_column :scenarios, :project_study, :text, array: true, default: []
    add_column :scenarios, :literature_reference, :text
    add_column :scenarios, :point_of_contact, :text
  end
end
