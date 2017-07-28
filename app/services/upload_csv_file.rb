require 'file_upload_status'
require 'encoding_detection'

class UploadCsvFile
  include EncodingDetection

  def initialize(user, model)
    @user = user
    @model = model
    @errors = {}
  end

  def call(path)
    initialize_data(path)
    @data.process
  end
end
