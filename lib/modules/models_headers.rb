require 'csv_upload_headers'
require 'csv_vertical_upload_headers'

class ModelsHeaders
  include CsvUploadHeaders
  include CsvVerticalUploadHeaders

  attr_reader :errors

  def initialize(path, encoding)
    @encoding = encoding
    initialize_headers(path)
    @errors = {}
    parse_headers(url_helpers.upload_template_models_path)
  end
end
