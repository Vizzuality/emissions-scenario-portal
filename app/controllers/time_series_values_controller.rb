class TimeSeriesValuesController < ApplicationController
  load_and_authorize_resource :model

  def upload
    file_name = :time_series_values_file
    redirect_url = model_scenarios_url(@model)
    handle_io_upload(file_name, redirect_url) do
      UploadTimeSeriesValues.new(current_user, @model).call(@uploaded_io)
    end and return
    @upload_errors = @upload_result.errors_to_hash
    set_filter_params
    @scenarios = @model.scenarios.fetch_all(@filter_params)
    render template: 'scenarios/index'
  end
end
