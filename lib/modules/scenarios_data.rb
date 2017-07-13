require 'csv_upload_data'
require 'csv_vertical_upload_data'
require 'scenarios_headers'

class ScenariosData
  include CsvUploadData
  include CsvVerticalUploadData

  DATA_CLASS = Scenario

  PROPERTY_NAMES = [
    :model_abbreviation,
    :model_version,
    :provider_name,
    :release_date,
    :name,
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
  ].freeze

  EXPECTED_PROPERTIES = build_properties(PROPERTY_NAMES).freeze

  def initialize(path, user, encoding)
    @path = path
    @user = user
    @encoding = encoding
    @headers = ScenariosHeaders.new(@path, @encoding)
    @template_url = '/esp_scenarios_template.csv'
    initialize_stats
  end

  def process_column(col, col_no)
    @errors[col_no] = {}

    model = model(col, @errors[col_no])
    scenario_attributes = {
      model_id: model.try(:id)
    }.merge(
      Hash[
        Scenario.attribute_infos.reject(&:reference?).map(&:name).map do |attr|
          [attr, value_for(col, attr)]
        end
      ]
    )
    if scenario_attributes[:name].blank?
      message = 'Scenario name must be present.'
      suggestion = 'Please fill in missing data.'
      @errors[col_no]['name'] = format_error(message, suggestion)
    end

    scenario = model && Scenario.where(
      model_id: model.id, name: scenario_attributes[:name]
    ).first

    scenario ||= Scenario.new
    scenario.attributes = scenario_attributes
    process_other_errors(@errors[col_no], scenario.errors) unless scenario.save

    if @errors[col_no].any?
      @number_of_records_failed += 1
    else
      @errors.delete(col_no)
    end
  end

  def multiple_selection?(property_name)
    Scenario.attribute_info(property_name).multiple?
  end
end
