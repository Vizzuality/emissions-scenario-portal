require 'csv'

class IndicatorsHeaders
  include CsvUploadHeaders

  EXPECTED_HEADERS = [
    {
      display_name: 'ESP Indicator Name',
      property_name: :slug
    },
    {
      display_name: 'Model Indicator Name',
      property_name: :model_slug
    },
    {
      display_name: 'Stackable sub-category?',
      property_name: :stackable_subcategory
    },
    {
      display_name: 'Standardized Unit',
      property_name: :unit
    },
    {
      display_name: 'Unit of Entry',
      property_name: :unit_of_entry
    },
    {
      display_name: 'Conversion factor',
      property_name: :conversion_factor
    },
    {
      display_name: 'Definition',
      property_name: :definition
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
    @errors = {}
    parse_headers('/esp_indicators_template.csv')
  end

  def parse_headers(template_url)
    expected_headers = EXPECTED_HEADERS.
      map do |eh|
        eh[:display_name].
          sub(/Model/, @model.abbreviation).
          downcase.
          gsub(/[^a-z0-9]/i, '')
      end
    @actual_headers = @headers.
      map { |ah| ah.downcase.gsub(/[^a-z0-9]/i, '') }.
      map do |header|
      expected_index = expected_headers.index(header)
      if expected_index.present?
        {
          display_name: header,
          expected_index: expected_index
        }
      else
        unrecognised_header_error(@errors, template_url, header, nil)
        {
          display_name: header
        }
      end
    end
  end
end
