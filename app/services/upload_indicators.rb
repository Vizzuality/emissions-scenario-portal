require 'indicators_data'
require 'file_upload_status'
require 'charlock_holmes'

class UploadIndicators
  def initialize(user, model)
    @user = user
    @model = model
    @errors = {}
  end

  def call(uploaded_io)
    @encoding_detection = CharlockHolmes::EncodingDetector.detect(
      File.read(uploaded_io.tempfile)
    )
    data = IndicatorsData.new(
      uploaded_io.tempfile, @user, @model, @encoding_detection[:encoding]
    )
    data.process
    FileUploadStatus.new(
      data.number_of_records,
      data.number_of_records_failed,
      data.errors
    )
  end
end
