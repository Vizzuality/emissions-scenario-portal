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

  def upload_template
    csv_template = TimeSeriesValuesUploadTemplate.new
    send_data(
      csv_template.export,
      type: 'text/csv; charset=utf-8; header=present',
      disposition: 'attachment; filename=time_series_values_upload_template.csv'
    )
  end

  private

  def redirect_after_upload_url(csv_upload = nil)
    model_scenarios_url(@model, csv_upload_id: csv_upload.try(:id))
  end
end
