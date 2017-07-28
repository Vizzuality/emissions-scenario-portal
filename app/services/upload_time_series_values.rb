require 'time_series_values_data'

class UploadTimeSeriesValues < UploadCsvFile
  def initialize_data(path)
    @data = TimeSeriesValuesData.new(
      path, @user, @model, encoding(path)
    )
  end
end
