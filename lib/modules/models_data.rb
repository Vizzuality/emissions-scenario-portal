require 'csv_upload_data'
require 'csv_vertical_upload_data'
require 'models_headers'

class ModelsData
  include CsvUploadData
  include CsvVerticalUploadData

  DATA_CLASS = Model

  PROPERTY_NAMES = [
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
  ].freeze

  EXPECTED_PROPERTIES = build_properties(PROPERTY_NAMES).freeze

  def initialize(path, user, encoding)
    @path = path
    @user = user
    @encoding = encoding
    @headers = ModelsHeaders.new(@path, @encoding)
    @template_url = '/esp_models_template.csv'
    initialize_stats
  end

  def process_column(col, col_no)
    @errors[col_no] = {}

    model_attributes =
      Hash[
        Model.attribute_infos.map(&:name).map do |attr|
          [attr, value_for(col, attr)]
        end
      ]
    if model_attributes[:abbreviation].blank?
      message = 'Model abbreviation must be present.'
      suggestion = 'Please fill in missing data.'
      @errors[col_no]['name'] = format_error(message, suggestion)
    end

    model = Model.where(
      abbreviation: model_attributes[:abbreviation]
    ).first

    if model && @user.cannot?(:manage, model)
      message = "Access denied to manage model (#{model.abbreviation})."
      suggestion = 'Please verify your team\'s permissions [here].'
      @errors[col_no]['model'] = format_error(
        message,
        suggestion,
        url: url_helpers.team_path(@user.team),
        placeholder: 'here'
      )
    end

    model ||= Model.new(team: @user.team)
    model.attributes = model_attributes
    process_other_errors(@errors[col_no], model.errors) unless model.save

    if @errors[col_no].any?
      @number_of_records_failed += 1
    else
      @errors.delete(col_no)
    end
  end

  def multiple_selection?(property_name)
    Model.attribute_info(property_name).multiple?
  end
end
