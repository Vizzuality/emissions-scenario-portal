class TimeSeriesValuesData
  include CsvUploadData

  def initialize(path, user, model, encoding)
    @path = path
    @user = user
    @model = model
    @encoding = encoding
    @headers = TimeSeriesValuesHeaders.new(@path, @model, @encoding)
    initialize_stats
  end

  def process_row(row, row_no)
    @fus.init_errors_for_row_or_col(row_no)

    values_by_year(row, row_no).each do |tsv|
      next if tsv.save
      process_other_errors(row_no, tsv.errors, tsv.year)
    end

    if @fus.errors_for_row_or_col?(row_no)
      @fus.increment_number_of_records_failed
    else
      @fus.clear_errors(row_no)
    end
  end

  def values_by_year(row, row_no)
    model = model(row, row_no)
    return [] if @fus.errors_for_key?(row_no, 'model')
    scenario = scenario(model, row, row_no)
    return [] if @fus.errors_for_key?(row_no, 'scenario')
    indicator = indicator(model, row, row_no)
    return [] if @fus.errors_for_key?(row_no, 'indicator')
    location = location(row, row_no)
    return [] if @fus.errors_for_key?(row_no, 'location')
    conversion_factor = conversion_factor(model, indicator, row, row_no)
    return [] if @fus.errors_for_key?(row_no, 'unit_of_entry')

    year_values = @headers.year_headers.map do |h|
      year = h[:display_name].to_i
      value = row[@headers.actual_index_of_year(h[:display_name])]
      begin
        value.blank? ? nil : [year, value.to_d * conversion_factor]
      rescue ArgumentError
        [year, value]
      end
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
        existing_tsv.indicator = indicator
        existing_tsv
      else
        TimeSeriesValue.new(
          scenario: scenario,
          indicator: indicator,
          location: location,
          year: year,
          value: value
        )
      end
    end
  end

  def scenario(model, row, row_no)
    return nil if model.nil?
    scenario_name = value_for(row, :scenario_name)
    if scenario_name.blank?
      message = 'Scenario must be present.'
      suggestion = 'Please fill in the scenario name.'
      @fus.add_error(row_no, 'scenario', format_error(message, suggestion))
      return nil
    end
    identification = "model: #{model.abbreviation}, scenario: \
#{scenario_name}"

    scenarios = Scenario.where(name: scenario_name, model_id: model.id)
    matching_object(
      scenarios,
      'scenario',
      identification,
      row_no,
      url_helpers.model_scenarios_path(model)
    )
  end

  def indicator(model, row, row_no)
    return nil if model.nil?
    indicator_name = value_for(row, :indicator_name)
    if indicator_name.blank?
      message = 'Indicator must be present.'
      suggestion = 'Please fill in the ESP indicator name.'
      @fus.add_error(row_no, 'indicator', format_error(message, suggestion))
      return nil
    end
    identification = "indicator: #{indicator_name}"

    indicator = matching_object(
      Indicator.where('lower(composite_name) = ?', indicator_name.to_s.downcase),
      'indicator',
      identification,
      row_no,
      url_helpers.model_indicators_path(model)
    )
  end

  def location(row, row_no)
    location_name = value_for(row, :location_name)
    identification = "location: #{location_name}"
    locations = Location.where(
      'iso_code = :location_name OR name = :location_name',
      location_name: location_name
    )
    order_clause = ActiveRecord::Base.send(
      :sanitize_sql_array,
      ['CASE WHEN iso_code = ? THEN 0 ELSE 1 END', location_name]
    )
    locations = locations.order(order_clause)
    matching_object(
      locations, 'location', identification, row_no, url_helpers.locations_path
    )
  end

  def conversion_factor(model, indicator, row, row_no)
    return nil if indicator.nil?
    unit_of_entry = value_for(row, :unit_of_entry)
    conversion_factor = 1
    return nil if unit_of_entry.nil?
    note = Note.find_by(indicator_id: indicator.id, model_id: model.id)
    if unit_of_entry != indicator.unit
      if unit_of_entry == note&.unit_of_entry
        conversion_factor = note.conversion_factor
      else
        message = "Conversion factor unavailable for unit of entry \
        #{unit_of_entry}."
        suggestion = "Please ensure unit of entry is compatible with [indicator]\
 standardized unit"
        link_options = {
          url: url_helpers.model_indicator_path(model, indicator),
          placeholder: 'indicator'
        }
        @fus.add_error(
          row_no, 'unit_of_entry',
          format_error(message, suggestion, link_options)
        )
      end
    end
    conversion_factor
  end

  def process_other_errors(row_or_col_no, object_errors, year)
    object_errors.each do |key, value|
      next if @fus.errors_for_key?(row_or_col_no, key.to_s)
      message = "Year #{year}: #{key.capitalize} #{value}."
      suggestion = ''
      @fus.add_error(row_or_col_no, year, format_error(message, suggestion))
    end
  end
end
