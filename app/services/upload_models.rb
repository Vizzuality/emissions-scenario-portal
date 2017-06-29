require 'scenarios_data'
require 'file_upload_status'

class UploadModels
  def initialize(user, _model)
    @user = user
    @errors = {}
  end

  def call(uploaded_io)
    data = ModelsData.new(uploaded_io.tempfile, @user)
    data.process
    FileUploadStatus.new(
      data.number_of_rows,
      data.number_of_rows_failed,
      data.errors
    )
  end
end