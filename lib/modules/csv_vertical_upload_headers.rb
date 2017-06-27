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

  def parse_headers(template_url)
    expected_headers = EXPECTED_HEADERS.
      map { |eh| eh.downcase.gsub(/[^a-z0-9]/i, '') }
    @static_headers = @headers[0..expected_headers.length - 1]
    @static_headers.each_with_index do |ah, idx|
      stripped = ah.downcase.gsub(/[^a-z0-9]/i, '')
      next if stripped == expected_headers[idx]
      message = "Unrecognised column header #{ah}, expecting \
#{EXPECTED_HEADERS[idx]}."
      suggestion = 'Please consult the [template] for correct structure.'
      @errors[ah] = FileUploadError.new(
        message, suggestion, url: template_url, placeholder: 'template'
      )
    end
    @data_headers = @headers[expected_headers.length..@headers.length - 1]
  end
end
