

class IndicatorsHeaders
  include CsvUploadHeaders

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
end
