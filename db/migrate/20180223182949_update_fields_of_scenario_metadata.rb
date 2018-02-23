class UpdateFieldsOfScenarioMetadata < ActiveRecord::Migration[5.1]
  def change
    add_column :scenarios, :year, :string
    add_column :scenarios, :url, :string
    add_column :scenarios, :socioeconomics, :text

    rename_column :scenarios, :climate_target_detailed, :climate_target
    rename_column :scenarios, :literature_reference, :reference

    remove_column :scenarios, :key_usage, :text
    remove_column :scenarios, :project, :text
    remove_column :scenarios, :geographic_coverage_country, :text, default: [], array: true
    remove_column :scenarios, :sectoral_coverage, :text, default: [], array: true
    remove_column :scenarios, :gas_and_pollutant_coverage, :text, default: [], array: true
    remove_column :scenarios, :policy_coverage_detailed, :text
    remove_column :scenarios, :technology_coverage_detailed, :text
    remove_column :scenarios, :energy_resource_coverage, :text, default: [], array: true
    remove_column :scenarios, :time_horizon, :text
    remove_column :scenarios, :time_step, :text
    remove_column :scenarios, :climate_target_date, :text
    remove_column :scenarios, :overshoot, :text
    remove_column :scenarios, :other_target_type, :text
    remove_column :scenarios, :population_assumptions, :text
    remove_column :scenarios, :large_scale_bioccs, :text
    remove_column :scenarios, :technology_assumptions, :text
    remove_column :scenarios, :gdp_assumptions, :text
    remove_column :scenarios, :emission_factors, :text
    remove_column :scenarios, :global_warming_potentials, :text
    remove_column :scenarios, :policy_cut_off_year_for_baseline, :text
  end
end
