require 'csv_upload_headers'
require 'csv_vertical_upload_headers'

class ScenariosHeaders
  include CsvUploadHeaders
  include CsvVerticalUploadHeaders

  attr_reader :errors

  def initialize(path, model, encoding)
    @encoding = encoding
    initialize_headers(path)
    @model = model
    @fus = FileUploadStatus.new(:headers, @headers.length, 0)
    parse_headers(url_helpers.upload_template_model_scenarios_path(@model))
  end
end
