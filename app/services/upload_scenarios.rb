require 'scenarios_data'

class UploadScenarios
  def initialize(user, model)
    @user = user
    @model = model
    @errors = {}
  end

  def call(uploaded_io)
    data = ScenariosData.new(uploaded_io.tempfile, @user)
    data.process
    FileUploadStatus.new(
      data.number_of_rows,
      data.number_of_rows_failed,
      data.errors
    )
  end
end
