require 'indicators_data'
require 'file_upload_status'

class UploadIndicators
  def initialize(user, model)
    @user = user
    @model = model
    @errors = {}
  end

  def call(uploaded_io)
    data = IndicatorsData.new(uploaded_io.tempfile, @user, @model)
    data.process
    FileUploadStatus.new(
      data.number_of_rows,
      data.number_of_rows_failed,
      data.errors
    )
  end
end
