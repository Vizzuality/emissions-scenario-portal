class TimeSeriesValuesData
  attr_reader :number_of_rows, :number_of_rows_failed, :errors

  def initialize(path, user)
    @path = path
    @user = user
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
    model = model(row, @errors[row_no])
    scenario = scenario(model, row, @errors[row_no])
    indicator = indicator(model, row, @errors[row_no])
    location = location(row, @errors[row_no])
    unit_of_entry = unit_of_entry(indicator, row, @errors[row_no])

    year_values = @headers.year_headers.map do |h|
      year = h[:display_name].to_i
      value = row[@headers.actual_index_of_year(h[:display_name])]
      value.blank? ? nil : [year, value.to_f]
    end.compact
    year_values.each do |year, value|
      tsv = TimeSeriesValue.new(
        scenario: scenario,
        indicator: indicator,
        location: location,
        year: year,
        value: value,
        unit_of_entry: unit_of_entry
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
    identification = "model: #{model_abbreviation}"

    models = Model.where(abbreviation: model_abbreviation)
    model = matching_object(models, 'model', identification, errors)
    return nil if model.nil?
    if @user.cannot?(:manage, model)
      errors['model'] = "Access denied: model (#{identification})"
      return nil
    end
    model
  end

  def scenario(model, row, errors)
    return nil if model.nil?
    scenario_name = value_for(row, :scenario_name)
    identification = "model: #{model.abbreviation}, scenario: \
    #{scenario_name}"

    scenarios = Scenario.where(name: scenario_name, model_id: model.id)
    matching_object(scenarios, 'scenario', identification, errors)
  end

  def indicator(model, row, errors)
    return nil if model.nil?
    indicator_slug = value_for(row, :indicator_slug)
    identification = "indicator: #{indicator_slug}"

    indicators = Indicator.find_all_by_slug(indicator_slug)
    model_indicators = indicators.where(model_id: model.id)
    indicators = model_indicators if model_indicators.any?
    matching_object(indicators, 'indicator', identification, errors)
  end

  def location(row, errors)
    location_name = value_for(row, :region)
    identification = "location: #{location_name}"
    locations = Location.where(name: location_name)
    matching_object(locations, 'location', identification, errors)
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

  def unit_of_entry(indicator, row, errors)
    return nil if indicator.nil?
    unit_of_entry = value_for(row, :unit_of_entry)
    return nil if unit_of_entry.nil?
    if unit_of_entry != indicator.unit &&
        unit_of_entry != indicator.unit_of_entry
      errors['unit_of_entry'] = "Conversion factor unavailable for unit of \
      entry #{unit_of_entry}"
    end
    unit_of_entry
  end
end
