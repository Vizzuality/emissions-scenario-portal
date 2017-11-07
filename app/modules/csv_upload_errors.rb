module CsvUploadErrors
  delegate :errors?, to: :@fus
  delegate :errors, to: :@fus

  def format_error(message, suggestion, link_options = nil)
    FileUploadError.new(
      message,
      suggestion,
      link_options
    )
  end
end
