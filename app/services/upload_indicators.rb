require 'indicators_data'

class UploadIndicators < UploadCsvFile
  def initialize_data(path)
    @data = IndicatorsData.new(
      path, @user, @model, encoding(path)
    )
  end
end
