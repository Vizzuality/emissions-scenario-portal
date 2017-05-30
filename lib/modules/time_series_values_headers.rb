require 'csv'

class TimeSeriesValuesHeaders
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
      property_name: :region
    },
    {
      display_name: 'ESP Slug',
      property_name: :indicator_slug
    },
    {
      display_name: 'Unit of Entry',
      property_name: :unit
    }
  ].freeze

  EXPECTED_PROPERTIES = Hash[
    EXPECTED_HEADERS.map.with_index do |header, index|
      [header[:property_name], header.merge(index: index)]
    end
  ].freeze

  attr_reader :errors

  def initialize(path)
    @headers = CSV.open(path, 'r', &:first).map(&:downcase)
    @errors = {}
    parse_headers
  end

  def parse_headers
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
        @errors[header] = 'Unrecognised header'
        {
          display_name: header
        }
      end
    end
  end

  def year_headers
    @actual_headers.select { |h| h[:year_header] }
  end

  def actual_index_for_property(property_name)
    expected_index = EXPECTED_PROPERTIES[property_name][:index]
    @actual_headers.index do |h|
      h[:expected_index] == expected_index
    end
  end

  def actual_index_of_year(year)
    @actual_headers.index do |h|
      h[:year_header] && h[:display_name] == year
    end
  end
end
