require 'scenarios_data'

class UploadScenarios < UploadCsvFile
  def initialize_data(path)
    @data = ScenariosData.new(
      path, @csv_upload.user, @csv_upload.model, encoding(path)
    )
  end
end
