class TimeSeriesValuesData
  attr_reader :number_of_rows, :number_of_rows_failed, :errors

  def initialize(path)
    @path = path
    @headers = TimeSeriesValuesHeaders.new(@path)
    @number_of_rows = File.foreach(@path).inject(0) { |c| c + 1 } - 1
    @number_of_rows_failed, @errors =
      if @headers.errors.any?
        [@number_of_rows, @headers.errors]
      else
        [0, {}]
      end
  end

  def process
    return if @headers.errors.any?
    CSV.open(@path, 'r', headers: true).each.with_index(2) do |row, row_no|
      process_row(row, row_no)
    end
  end

  def process_row(row, row_no)
    @errors[row_no] = {}
    scenario = scenario(row, @errors[row_no])
    indicator = indicator(row, @errors[row_no])
    location = location(row, @errors[row_no])
    unit = value_for(row, :unit)
    unit != indicator.unit &&
      conversion_factor = conversion_factor(row, @errors[row_no])

    year_values = @headers.year_headers.map do |h|
      year = h[:display_name].to_i
      value = row[@headers.actual_index_of_year(h[:display_name])]
      value.blank? ? nil : [year, value]
    end.compact
    year_values.each do |year, value|
      value *= conversion_factor if conversion_factor
      tsv = TimeSeriesValue.new(
        scenario: scenario,
        indicator: indicator,
        location: location,
        year: year,
        value: value
      )
      @errors[row_no][year] = tsv.errors unless tsv.save
    end
    if @errors[row_no].any?
      @number_of_rows_failed += 1
    else
      @errors.delete(row_no)
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

  def location(row, errors)
    location_name = value_for(row, :region)
    location_identification = "location: #{location_name}"
    locations = Location.where(name: location_name)
    matching_object(locations, 'location', location_identification, errors)
  end

  def matching_object(object_collection, object_type, identification, errors)
    if object_collection.count > 1
      errors[object_type] = "More than one #{object_type} found \
      (#{identification}"
      nil
    elsif object_collection.count.zero?
      errors[object_type] = "#{object_type.capitalize} does not exist \
      (#{identification})"
      nil
    else
      object_collection.first
    end
  end

  def conversion_factor(row, errors)
    conversion_factor = value_for(row, :conversion_factor)
    format_ok = conversion_factor && conversion_factor.match?(/\A\d+\z/)
    unless format_ok
      errors[:conversion_factor] = "Conversion factor not given \
      correctly where unit of entry different from standardised unit"
      return nil
    end
    conversion_factor.to_i
  end
end
