require 'csv'

class ModelsHeaders
  include CsvUploadHeaders

  EXPECTED_HEADERS = [
    :abbreviation,
    :full_name,
    :current_version,
    :maintainer_name,
    :description,
    :publications_and_notable_projects,
    :citation,
    :url,
    :point_of_contact,
    :parent_model,
    :descendent_models,
    :programming_language,
    :development_year,
    :license,
    :availability,
    :expertise,
    :expertise_detailed,
    :platform_detailed,
    :purpose_or_objective,
    :key_usage,
    :concept,
    :solution_method,
    :equilibrium_type,
    :anticipation,
    :scenario_coverage,
    :scenario_coverage_detailed,
    :geographic_coverage,
    :geographic_coverage_region,
    :geographic_coverage_country,
    :sectoral_coverage,
    :gas_and_pollutant_coverage,
    :policy_coverage,
    :policy_coverage_detailed,
    :technology_coverage,
    :technology_coverage_detailed,
    :energy_resource_coverage,
    :base_year,
    :time_horizon,
    :time_step,
    :spatial_resolution,
    :population_assumptions,
    :gdp_assumptions,
    :other_assumptions,
    :input_data,
    :behaviour,
    :land_use
  ].map do |property_name|
    {
      display_name: I18n.t(Model.key_for_name(property_name)),
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
    parse_headers('/esp_models_template.csv')
  end
end
