class TimeSeriesValuesController < ApplicationController
  def upload
    @model = Model.find(params[:model_id])
    handle_io_upload(:time_series_values_file, model_scenarios_url(@model)) do
      CsvUpload.create(
        user: current_user,
        model: @model,
        service_type: 'UploadTimeSeriesValues',
        data: @uploaded_io
      )
    end
  end

  private

  def redirect_after_upload_url(csv_upload = nil)
    model_scenarios_url(@model, csv_upload_id: csv_upload.try(:id))
  end
end
