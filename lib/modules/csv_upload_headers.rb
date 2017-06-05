require 'csv'

module CsvUploadHeaders
  def parse_headers
    expected_headers = self.class::EXPECTED_HEADERS.
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
    expected_index = self.class::EXPECTED_PROPERTIES[property_name][:index]
    @actual_headers.index do |h|
      h[:expected_index] == expected_index
    end
  end
end
