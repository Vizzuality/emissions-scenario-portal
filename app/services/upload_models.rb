require 'models_data'

class UploadModels < UploadCsvFile
  def initialize(user)
    @user = user
    @errors = {}
  end

  def initialize_data(path)
    @data = ModelsData.new(
      path, @user, encoding(path)
    )
  end
end
