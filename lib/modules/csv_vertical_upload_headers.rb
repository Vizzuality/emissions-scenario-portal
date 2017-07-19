module CsvVerticalUploadHeaders
  attr_reader :headers, :static_headers, :data_headers

  # expected to come in specified order, followed by data columns
  EXPECTED_HEADERS = [
    'Category',
    'Indicator',
    'Definition/Input Explanation',
    'Data Type',
    'Picklist options (Data Entry)'
  ].freeze

  ATTRIBUTE_NAME_INDEX = 1 # Indicator column

  def parse_headers(template_url)
    expected_headers = EXPECTED_HEADERS.
      map { |eh| eh.downcase.gsub(/[^a-z0-9]/i, '') }
    @static_headers = @headers[0..expected_headers.length - 1]
    @static_headers.each_with_index do |ah, idx|
      stripped = ah.downcase.gsub(/[^a-z0-9]/i, '')
      next if stripped == expected_headers[idx]
      unrecognised_header_error(template_url, ah, EXPECTED_HEADERS[idx])
    end
    @data_headers = @headers[expected_headers.length..@headers.length - 1]
  end
end
