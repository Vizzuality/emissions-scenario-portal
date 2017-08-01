require 'models_data'

class UploadModels < UploadCsvFile
  def initialize_data(path)
    @data = ModelsData.new(
      path, @csv_upload.user, encoding(path)
    )
  end
end
