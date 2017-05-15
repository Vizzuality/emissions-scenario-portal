class TimeSeriesValuesController < ApplicationController
  def upload
    @model = Model.find(params[:model_id])
    @uploaded_io = params[:time_series_values_file]
    # TODO: pass current user into service object
    result = UploadTimeSeriesValues.new(nil, @model).call(@uploaded_io)
    render json: result
  end
end
