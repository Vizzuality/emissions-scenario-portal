require 'scenarios_data'

class UploadScenarios < UploadCsvFile
  def initialize_data(path)
    @data = ScenariosData.new(
      path, @user, @model, encoding(path)
    )
  end
end
