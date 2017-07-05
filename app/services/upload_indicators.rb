require 'indicators_data'

class UploadIndicators < UploadCsvFile
  def initialize_data(uploaded_io)
    @data = IndicatorsData.new(
      uploaded_io.tempfile, @user, @model, encoding(uploaded_io.tempfile)
    )
  end
end
