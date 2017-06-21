require 'csv'

class ScenariosHeaders
  include CsvUploadHeaders

  EXPECTED_HEADERS = [
    :model_abbreviation,
    :model_version,
    :name,
    :proposed_portal_name,
    :provider_type,
    :provider_name,
    :release_date,
    :category,
    :description,
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
    :climate_target,
    :emissions_target,
    :large_scale_bioccs,
    :climate_policy_instrument,
    :technology_assumptions,
    :gdp_assumptions,
    :population_assumptions,
    :discount_rates,
    :emission_factors,
    :global_warming_potentials,
    :policy_cut_off_year_for_baseline,
    :project_study,
    :literature_reference,
    :point_of_contact
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

  def parse_headers(template_url)
    expected_headers = EXPECTED_HEADERS.
      map { |eh| eh[:display_name].downcase.gsub(/[^a-z0-9]/i, '') }
    @actual_headers = @headers.
      map { |ah| ah.downcase.gsub(/[^a-z0-9]/i, '') }.
      map do |header|
      expected_index = expected_headers.index(header)
      if expected_index.present?
        {
          display_name: header,
          expected_index: expected_index
        }
      else
        message = 'Unrecognised column header.'
        suggestion = 'Please consult the [template] for correct structure.'
        @errors[header] = FileUploadError.new(
          message, suggestion, url: template_url, placeholder: 'template'
        )
        {
          display_name: header
        }
      end
    end
  end
end
