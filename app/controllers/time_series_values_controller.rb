class TimeSeriesValuesController < ApplicationController
  def upload
    model = Model.find(params[:model_id])
    authorize(TimeSeriesValue, :create?)
    csv_upload = CsvUpload.new(
      user: current_user,
      model: model,
      service_type: 'UploadTimeSeriesValues',
      data: params[:time_series_values_file]
    )

    if csv_upload.save
      job = CsvUploadJob.perform_later(csv_upload.id)
      csv_upload.update!(job_id: job.job_id)
      redirect_to(
        model_scenarios_url(model, csv_upload_id: csv_upload.id),
        notice: 'File has been queued for processing. Please refresh.'
      )
    else
      redirect_to(
        model_scenarios_url(model),
        alert: csv_upload.errors.full_messages.join(', ')
      )
    end
  end
end
