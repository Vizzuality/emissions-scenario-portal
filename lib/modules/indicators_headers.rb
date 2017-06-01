require 'csv'

class IndicatorsHeaders
  EXPECTED_HEADERS = [
    {
      display_name: 'ESP Slug',
      property_name: :slug
    },
    {
      display_name: 'Model Indicator name',
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

  def initialize(path, model)
    @headers = CSV.open(path, 'r', &:first).map(&:downcase)
    @model = model
    @errors = {}
    parse_headers
  end

  def parse_headers
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
        @errors[header] = 'Unrecognised header'
        {
          display_name: header
        }
      end
    end
  end

  def actual_index_for_property(property_name)
    expected_index = EXPECTED_PROPERTIES[property_name][:index]
    @actual_headers.index do |h|
      h[:expected_index] == expected_index
    end
  end
end
