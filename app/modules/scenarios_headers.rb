class ScenariosHeaders
  include CsvUploadHeaders
  include CsvVerticalUploadHeaders

  def initialize(path, model, encoding)
    @encoding = encoding
    initialize_headers(path)
    @model = model
    @fus = FileUploadStatus.new(:headers, @headers.length, 0)
    parse_headers(url_helpers.template_path(:scenarios))
  end
end
