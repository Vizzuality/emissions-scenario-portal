require 'time_series_values_data'
require 'file_upload_status'

class UploadTimeSeriesValues
  def initialize(user, model)
    @user = user
    @model = model
    @errors = {}
  end

  def call(uploaded_io)
    data = TimeSeriesValuesData.new(uploaded_io.tempfile, @user)
    data.process
    FileUploadStatus.new(
      data.number_of_rows,
      data.number_of_rows_failed,
      data.errors
    )
  end
end
