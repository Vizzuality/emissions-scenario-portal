require 'time_series_values_upload_template'

class TimeSeriesValuesController < ApplicationController
  load_and_authorize_resource :model

  def upload
    handle_io_upload(:time_series_values_file, model_scenarios_url(@model)) do
      UploadTimeSeriesValues.new(current_user, @model).call(@uploaded_io)
    end and return
    @scenarios = @model.scenarios.fetch_all(@filter_params)
    render template: 'scenarios/index'
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
