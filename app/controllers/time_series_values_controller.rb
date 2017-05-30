class TimeSeriesValuesController < ApplicationController
  def upload
    @model = Model.find(params[:model_id])
    @uploaded_io = params[:time_series_values_file]
    redirect_to model_scenarios_url(@model),
      alert: 'Please provide an upload file' and return unless @uploaded_io.present?
    result = UploadTimeSeriesValues.new(current_user, @model).call(@uploaded_io)
    render json: result
  end
end
