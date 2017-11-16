class ModelsHeaders
  include CsvUploadHeaders
  include CsvVerticalUploadHeaders

  def initialize(path, encoding)
    @encoding = encoding
    initialize_headers(path)
    @fus = FileUploadStatus.new(:headers, @headers.length, 0)
    parse_headers(url_helpers.upload_template_models_path)
  end
end
