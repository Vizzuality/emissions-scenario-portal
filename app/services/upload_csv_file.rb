require 'file_upload_status'
require 'encoding_detection'

class UploadCsvFile
  include EncodingDetection

  def initialize(user, model)
    @user = user
    @model = model
    @errors = {}
  end

  def call(uploaded_io)
    initialize_data(uploaded_io)
    @data.process
    FileUploadStatus.new(
      @data.error_type,
      @data.number_of_records,
      @data.number_of_records_failed,
      @data.errors
    )
  end
end
