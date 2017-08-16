require 'indicators_data'

class UploadIndicators < UploadCsvFile
  def initialize_data(path)
    @data = IndicatorsData.new(
      path, @csv_upload.user, @csv_upload.model, encoding(path)
    )
  end
end
