require 'csv_upload_headers'
require 'csv_vertical_upload_headers'

class ScenariosHeaders
  include CsvUploadHeaders
  include CsvVerticalUploadHeaders

  attr_reader :errors

  def initialize(path, encoding)
    @encoding = encoding
    initialize_headers(path)
    @errors = {}
    parse_headers('/esp_scenarios_template.csv')
  end
end
