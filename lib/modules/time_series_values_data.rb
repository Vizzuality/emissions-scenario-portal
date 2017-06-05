require 'time_series_values_headers'

class TimeSeriesValuesData
  include CsvUploadData
  attr_reader :number_of_rows, :number_of_rows_failed, :errors

  def initialize(path, user)
    @path = path
    @user = user
    @headers = TimeSeriesValuesHeaders.new(@path)
    initialize_stats
  end

  def process_row(row, row_no)
    @errors[row_no] = {}

    values_by_year(row, @errors[row_no]).each do |tsv|
      @errors[row_no][tsv.year] = tsv.errors unless tsv.save
    end

    if @errors[row_no].any?
      @number_of_rows_failed += 1
    else
      @errors.delete(row_no)
    end
  end

  def values_by_year(row, errors)
    model = model(row, errors)
    return [] if errors['model'].present?
    scenario = scenario(model, row, errors)
    return [] if errors['scenario'].present?
    indicator = indicator(model, row, errors)
    return [] if errors['indicator'].present?
    location = location(row, errors)
    return [] if errors['location'].present?
    unit_of_entry = unit_of_entry(indicator, row, errors)
    return [] if errors['unit_of_entry'].present?

    year_values = @headers.year_headers.map do |h|
      year = h[:display_name].to_i
      value = row[@headers.actual_index_of_year(h[:display_name])]
      value.blank? ? nil : [year, value.to_f]
    end.compact

    year_values.map do |year, value|
      existing_tsv = scenario && indicator && location &&
        TimeSeriesValue.where(
          scenario_id: scenario.id,
          indicator_id: indicator.id,
          location_id: location.id,
          year: year
        ).first

      if existing_tsv
        existing_tsv.value = value
        existing_tsv.unit_of_entry = unit_of_entry
        existing_tsv
      else
        TimeSeriesValue.new(
          scenario: scenario,
          indicator: indicator,
          location: location,
          year: year,
          value: value,
          unit_of_entry: unit_of_entry
        )
      end
    end
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
    indicator_name = value_for(row, :indicator_name)
    identification = "indicator: #{indicator_name}"

    indicators = Indicator.where(alias: indicator_name)
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
