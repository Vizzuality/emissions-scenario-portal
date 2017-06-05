class TimeSeriesValuesController < ApplicationController
  load_and_authorize_resource :model

  def upload
    handle_io_upload(
      :time_series_values_file,
      UploadTimeSeriesValues,
      model_scenarios_url(@model)
    )
  end
end
