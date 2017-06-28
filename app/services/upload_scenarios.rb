require 'scenarios_data'

class UploadScenarios < UploadCsvFile
  def initialize_data(uploaded_io)
    @data = ScenariosData.new(
      uploaded_io.tempfile, @user, encoding(uploaded_io.tempfile)
    )
  end
end
