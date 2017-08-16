require 'time_series_values_data'

class UploadTimeSeriesValues < UploadCsvFile
  def initialize_data(path)
    @data = TimeSeriesValuesData.new(
      path, @csv_upload.user, @csv_upload.model, encoding(path)
    )
  end
end
