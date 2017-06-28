require 'time_series_values_data'

class UploadTimeSeriesValues < UploadCsvFile
  def initialize_data(uploaded_io)
    @data = TimeSeriesValuesData.new(
      uploaded_io.tempfile, @user, encoding(uploaded_io.tempfile)
    )
  end
end
