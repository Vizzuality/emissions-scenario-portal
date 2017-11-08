require 'csv_upload_data'
require 'csv_vertical_upload_data'
require 'scenarios_headers'

class ScenariosData
  include CsvUploadData
  include CsvVerticalUploadData

  DATA_CLASS = Scenario

  PROPERTY_NAMES = [
    :model_abbreviation,
    :name,
    :category,
    :purpose_or_objective,
    :description,
    :key_usage,
    :project,
    :literature_reference,
    :geographic_coverage_country,
    :sectoral_coverage,
    :gas_and_pollutant_coverage,
    :policy_coverage,
    :technology_coverage,
    :energy_resource_coverage,
    :time_horizon,
    :time_step,
    :geographic_coverage_region,
    :policy_coverage_detailed,
    :technology_coverage_detailed,
    :climate_target_type,
    :climate_target_detailed,
    :climate_target_date,
    :overshoot,
    :other_target_type,
    :other_target,
    :large_scale_bioccs,
    :technology_assumptions,
    :gdp_assumptions,
    :population_assumptions,
    :global_warming_potentials,
    :policy_cut_off_year_for_baseline,
    :burden_sharing,
    :discount_rates,
    :emission_factors
  ].freeze

  EXPECTED_PROPERTIES = build_properties(PROPERTY_NAMES).freeze

  def initialize(path, user, model, encoding)
    @path = path
    @user = user
    @model = model
    @encoding = encoding
    @headers = ScenariosHeaders.new(@path, @model, @encoding)
    @template_url = url_helpers.upload_template_model_scenarios_path(@model)
    initialize_stats
  end

  def process_column(col, col_no)
    @fus.init_errors_for_row_or_col(col_no)

    model = model(col, col_no)
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
      @fus.add_error(col_no, 'name', format_error(message, suggestion))
    end

    scenario = model && Scenario.where(
      model_id: model.id, name: scenario_attributes[:name]
    ).first

    scenario ||= Scenario.new
    scenario.attributes = scenario_attributes
    process_other_errors(col_no, scenario.errors) unless scenario.save

    if @fus.errors_for_row_or_col?(col_no)
      @fus.increment_number_of_records_failed
    else
      @fus.clear_errors(col_no)
    end
  end

  def multiple_selection?(property_name)
    Scenario.attribute_info(property_name).multiple?
  end
end