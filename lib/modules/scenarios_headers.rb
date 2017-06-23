require 'csv'

class ScenariosHeaders
  include CsvUploadHeaders

  EXPECTED_HEADERS = [
    :model_abbreviation,
    :model_version,
    :name,
    :provider_name,
    :release_date,
    :category,
    :purpose_or_objective,
    :description,
    :key_usage,
    :project,
    :literature_reference,
    :geographic_coverage_region,
    :geographic_coverage_country,
    :sectoral_coverage,
    :gas_and_pollutant_coverage,
    :policy_coverage,
    :policy_coverage_detailed,
    :technology_coverage,
    :technology_coverage_detailed,
    :energy_resource_coverage,
    :time_horizon,
    :time_step,
    :climate_target_type,
    :climate_target_detailed,
    :climate_target_date,
    :overshoot,
    :other_target_type,
    :other_target,
    :burden_sharing,
    :large_scale_bioccs,
    :technology_assumptions,
    :gdp_assumptions,
    :population_assumptions,
    :discount_rates,
    :emission_factors,
    :global_warming_potentials,
    :policy_cut_off_year_for_baseline
  ].map do |property_name|
    {
      display_name: I18n.t(Scenario.key_for_name(property_name)),
      property_name: property_name
    }
  end.freeze

  EXPECTED_PROPERTIES = Hash[
    EXPECTED_HEADERS.map.with_index do |header, index|
      [header[:property_name], header.merge(index: index)]
    end
  ].freeze

  attr_reader :errors

  def initialize(path)
    initialize_headers(path)
    @errors = {}
    parse_headers('/esp_scenarios_template.csv')
  end
end
