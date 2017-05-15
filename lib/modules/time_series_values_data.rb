class TimeSeriesValuesData
  attr_reader :number_of_rows_read, :number_of_rows_saved, :errors

  def initialize(path, headers)
    @path = path
    @headers = headers
    @number_of_rows_read = 0
    @number_of_rows_saved = 0
    @errors = {}
  end

  def process
    CSV.open(@path, 'r', headers: true).each_with_index do |row, row_no|
      @number_of_rows_read += 1
      process_row(row, row_no)
    end
  end

  def process_row(row, row_no)
    @errors[row_no] = []
    scenario = scenario(row, @errors[row_no])
    indicator = indicator(row, @errors[row_no])
    # TODO: should this link to a dictionary table or just text field
    # region = value_for(row, :region)
    unit = value_for(row, :unit)
    conversion_factor = value_for(row, :conversion_factor)

    @headers.year_headers.each do |h|
      year = h[:display_name].to_i
      value = row[@headers.actual_index_of_year(h[:display_name])]
      value *= conversion_factor if indicator.present? && unit != indicator.unit
      next if value.blank?

      tsv = TimeSeriesValue.new(
        scenario: scenario,
        indicator: indicator,
        # region: region, # TODO: implement region
        year: year,
        value: value
      )
      if tsv.valid? && tsv.save
        @number_of_rows_saved += 1
      else
        @errors[row_no] << tsv.errors
      end
    end
  end

  def value_for(row, property_name)
    row[@headers.actual_index_for_property(property_name)]
  end

  def model(row, errors)
    model_abbreviation = value_for(row, :model_abbreviation)
    model_identification = "model: #{model_abbreviation}"

    models = Model.where(abbreviation: model_abbreviation)
    matching_object(models, 'model', model_identification, errors)
  end

  def scenario(row, errors)
    model = model(row, errors)
    return nil if model.nil?
    scenario_name = value_for(row, :scenario_name)
    scenario_identification = "model: #{model.abbreviation}, scenario: \
    #{scenario_name}"

    scenarios = Scenario.where(name: scenario_name, model_id: model.id)
    matching_object(scenarios, 'scenario', scenario_identification, errors)
  end

  def indicator(row, errors)
    indicator_name = value_for(row, :indicator_name)
    indicator_stack_family = value_for(row, :indicator_stack_family)
    indicator_category = value_for(row, :indicator_category)
    # TODO: why here?
    # indicator_definition = value_for(row, :indicator_definition)
    indicator_unit = value_for(row, :indicator_unit)
    indicator_identification = "indicator: #{indicator_category} | \"
      #{indicator_stack_family} | #{indicator_name}, unit: #{indicator_unit}"

    indicators = Indicator.where(
      name: indicator_name,
      stack_family: indicator_stack_family,
      category: indicator_category,
      unit: indicator_unit
    )
    matching_object(indicators, 'indicator', indicator_identification, errors)
  end

  def matching_object(object_collection, object_type, identification, errors)
    if object_collection.count > 1
      errors << "More than one #{object_type} found (#{identification}"
      nil
    elsif object_collection.count.zero?
      errors << "#{object_type.capitalize} does not exist (#{identification})"
      nil
    else
      object_collection.first
    end
  end
end
