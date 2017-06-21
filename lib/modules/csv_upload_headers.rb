require 'csv'
require 'file_upload_error'

module CsvUploadHeaders
  def initialize_headers(path)
    @headers = CSV.open(path, 'r') do |csv|
      headers = csv.first
      break [] unless headers.present?
      # detect any blank columns to the right which might ruin the parsing
      blank_columns_to_the_right = headers.reverse.inject(0) do |memo, obj|
        break memo unless obj.blank?
        memo + 1
      end
      break headers[0..(headers.length - blank_columns_to_the_right - 1)]
    end.map(&:downcase)
  end

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
        message = 'Unrecognised column header.'
        suggestion = 'Please consult the template for correct structure.'
        # TODO url
        @errors[header] = FileUploadError.new(
          message, suggestion, 'TODO', 'TODO'
        )
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
