module CsvUploadHelpers
  def actual_index_for_property(property_name)
    expected_index = self.class::EXPECTED_PROPERTIES[property_name][:index]
    @actual_headers.index do |h|
      h[:expected_index] == expected_index
    end
  end

  def unrecognised_header_error(template_url, header, expected_header)
    message = "Unrecognised header #{header}"
    message += ", expecting #{expected_header}" if expected_header.present?
    message += '.'
    suggestion = 'Please consult the [template] for correct structure.'
    link_options = {url: template_url, placeholder: 'template'}
    @fus.add_header_error(
      header, FileUploadError.new(message, suggestion, link_options)
    )
  end
end
