require 'models_data'
require 'file_upload_status'
require 'charlock_holmes'

class UploadModels
  def initialize(user, _model)
    @user = user
    @errors = {}
  end

  def call(uploaded_io)
    @encoding_detection = CharlockHolmes::EncodingDetector.detect(
      File.read(uploaded_io.tempfile)
    )
    data = ModelsData.new(
      uploaded_io.tempfile, @user, @encoding_detection[:encoding]
    )
    data.process
    FileUploadStatus.new(
      data.number_of_records,
      data.number_of_records_failed,
      data.errors
    )
  end
end
