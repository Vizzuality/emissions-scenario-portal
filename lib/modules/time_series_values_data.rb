class TimeSeriesValuesData
  attr_reader :number_of_rows, :number_of_rows_failed, :errors

  def initialize(path)
    @path = path
    @headers = TimeSeriesValuesHeaders.new(@path)
    @number_of_rows = File.foreach(@path).count - 1
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
    model = model(row, @errors[row_no]) # TODO: permission check
    scenario = scenario(model, row, @errors[row_no]) # TODO: permission check
    indicator = indicator(model, row, @errors[row_no]) # TODO: permission check
    location = location(row, @errors[row_no])
    conversion_factor = conversion_factor(indicator, row, @errors[row_no])

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

  def scenario(model, row, errors)
    return nil if model.nil?
    scenario_name = value_for(row, :scenario_name)
    scenario_identification = "model: #{model.abbreviation}, scenario: \
    #{scenario_name}"

    scenarios = Scenario.where(name: scenario_name, model_id: model.id)
    matching_object(scenarios, 'scenario', scenario_identification, errors)
  end

  def indicator(model, row, errors)
    return nil if model.nil?
    indicator_slug = value_for(row, :indicator_slug)
    indicator_identification = "indicator: #{indicator_slug}"

    indicators = Indicator.find_all_by_slug(indicator_slug)
    model_indicators = indicators.where(model_id: model.id)
    indicators = model_indicators if model_indicators.any?
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

  def conversion_factor(indicator, row, errors)
    return nil if indicator.nil?
    unit = value_for(row, :unit)
    # no need to apply conversion if value given in standard unit
    return nil if unit == indicator.unit
    # if value not given in either standard unit or unit of entry
    if unit != indicator.unit_of_entry
      errors[:unit] = "Conversion factor unavailable for unit of entry #{unit}"
      return nil
    end
    indicator.conversion_factor.to_i
  end
end
