class IndicatorsHeaders
  include CsvUploadHeaders

  EXPECTED_HEADERS = [
    {
      display_name: 'ESP Indicator Name',
      property_name: :slug
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
      display_name: 'Definition',
      property_name: :definition
    }
  ].freeze

  EXPECTED_PROPERTIES = Hash[
    EXPECTED_HEADERS.map.with_index do |header, index|
      [header[:property_name], header.merge(index: index)]
    end
  ].freeze

  def initialize(path, encoding)
    @encoding = encoding
    initialize_headers(path)
    @fus = FileUploadStatus.new(:headers, @headers.length, 0)
    template_path = url_helpers.template_path(:indicators)
    parse_headers(template_path)
  end

  def parse_headers(template_url)
    expected_headers = EXPECTED_HEADERS.map { |eh| eh[:display_name] }
    expected_headers = expected_headers.map do |eh|
      eh.downcase.gsub(/[^a-z0-9]/i, '')
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
        unrecognised_header_error(template_url, header, nil)
        {
          display_name: header
        }
      end
    end
  end
end
