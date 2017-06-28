require 'models_data'

class UploadModels < UploadCsvFile
  def initialize(user, _model)
    @user = user
    @errors = {}
  end

  def initialize_data(uploaded_io)
    @data = ModelsData.new(
      uploaded_io.tempfile, @user, encoding(uploaded_io.tempfile)
    )
  end
end
