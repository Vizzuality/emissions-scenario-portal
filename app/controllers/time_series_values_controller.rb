require 'time_series_values_upload_template'

class TimeSeriesValuesController < ApplicationController
  load_and_authorize_resource :model

  def upload
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
end
