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
    :url,
    :programming_language,
    :development_year,
    :license,
    :availability,
    :expertise,
    :platform_detailed,
    :publications_and_notable_projects,
    :citation,
    :point_of_contact,
    :parent_model,
    :descendent_models,
    :expertise_detailed,
    :concept,
    :solution_method,
    :equilibrium_type,
    :anticipation,
    :purpose_or_objective,
    :key_usage,
    :scenario_coverage,
    :scenario_coverage_detailed,
    :geographic_coverage_country,
    :sectoral_coverage,
    :gas_and_pollutant_coverage,
    :policy_coverage,
    :technology_coverage,
    :energy_resource_coverage,
    :base_year,
    :time_horizon,
    :time_step,
    :geographic_coverage,
    :policy_coverage_detailed,
    :technology_coverage_detailed,
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
    @template_url = url_helpers.template_path(:models)
    initialize_stats
  end

  def process_column(col, col_no)
    @fus.init_errors_for_row_or_col(col_no)

    model_attributes =
      Hash[
        Model.attribute_infos.map(&:name).map do |attr|
          [attr, value_for(col, attr)]
        end
      ]
    if model_attributes[:abbreviation].blank?
      message = 'Model abbreviation must be present.'
      suggestion = 'Please fill in missing data.'
      @fus.add_error(col_no, 'name', format_error(message, suggestion))
    end

    model = Model.where(
      abbreviation: model_attributes[:abbreviation]
    ).first

    if model && !@user.admin? && @user.team != model.team
      message = "Access denied to manage model (#{model.abbreviation})."
      suggestion = 'Please verify your team\'s permissions [here].'
      link_options = {
        url: url_helpers.team_path(@user.team), placeholder: 'here'
      }
      @fus.add_error(
        col_no, 'model',
        format_error(message, suggestion, link_options)
      )
    end

    model ||= Model.new(team: @user.team)
    model.attributes = model_attributes
    process_other_errors(col_no, model.errors) unless model.save

    if @fus.errors_for_row_or_col?(col_no)
      @fus.increment_number_of_records_failed
    else
      @fus.clear_errors(col_no)
    end
  end

  def multiple_selection?(property_name)
    Model.attribute_info(property_name).multiple?
  end
end
