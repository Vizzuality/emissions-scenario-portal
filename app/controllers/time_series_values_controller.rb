class TimeSeriesValuesController < ApplicationController
  def upload
    @model = Model.find(params[:model_id])
    @uploaded_io = params[:time_series_values_file]
    unless @uploaded_io.present?
      redirect_to(
        model_scenarios_url(@model),
        alert: 'Please provide an upload file'
      ) and return
    end
    result = UploadTimeSeriesValues.new(current_user, @model).call(@uploaded_io)
    render json: result
  end
end
