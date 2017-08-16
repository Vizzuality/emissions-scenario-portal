require 'file_upload_status'
require 'encoding_detection'

class UploadCsvFile
  include EncodingDetection

  def initialize(csv_upload)
    @csv_upload = csv_upload
    @errors = {}
  end

  def call
    path = Paperclip.io_adapters.for(@csv_upload.data).path
    initialize_data(path)
    @data.process
  end
end
