require 'csv_upload_headers'

class TimeSeriesValuesHeaders
  include CsvUploadHeaders

  EXPECTED_HEADERS = [
    {
      display_name: 'Model',
      property_name: :model_abbreviation
    },
    {
      display_name: 'Scenario',
      property_name: :scenario_name
    },
    {
      display_name: 'Region',
      property_name: :location_name
    },
    {
      display_name: 'ESP Indicator Name',
      property_name: :indicator_name
    },
    {
      display_name: 'Unit of Entry',
      property_name: :unit_of_entry
    }
  ].freeze

  EXPECTED_PROPERTIES = Hash[
    EXPECTED_HEADERS.map.with_index do |header, index|
      [header[:property_name], header.merge(index: index)]
    end
  ].freeze

  attr_reader :errors

  def initialize(path, model, encoding)
    @encoding = encoding
    initialize_headers(path)
    @model = model
    @fus = FileUploadStatus.new(:headers, @headers.length, 0)
    parse_headers(
      url_helpers.upload_time_series_template_model_scenarios_path(@model)
    )
  end

  def parse_headers(template_url)
    expected_headers = EXPECTED_HEADERS.
      map { |eh| eh[:display_name].downcase.gsub(/[^a-z0-9]/i, '') }
    @actual_headers = @headers.
      map { |ah| ah.downcase.gsub(/[^a-z0-9]/i, '') }.
      map do |header|
      expected_index = expected_headers.index(header)
      if expected_index.present?
        {
          display_name: header,
          expected_index: expected_index
        }
      elsif header.match?(/\d\d\d\d/)
        {
          display_name: header,
          year_header: true
        }
      else
        unrecognised_header_error(template_url, header, nil)
        {
          display_name: header
        }
      end
    end
  end

  def year_headers
    @actual_headers.select { |h| h[:year_header] }
  end

  def actual_index_of_year(year)
    @actual_headers.index do |h|
      h[:year_header] && h[:display_name] == year
    end
  end
end
