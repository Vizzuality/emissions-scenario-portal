class ApplicationController < ActionController::Base
  include Pundit

  protect_from_forgery with: :exception
  before_action :authenticate_user!

  rescue_from Pundit::NotAuthorizedError do |exception|
    respond_to do |format|
      format.json { head :forbidden }
      format.html do
        redirect_to(
          root_url,
          alert: "You are not authorized to perform this action"
        )
      end
    end
  end

  private

  def set_nav_links
    return unless @model.present?
    @nav_links = [
      {name: 'Overview', path: model_url(@model), key: 'models'},
      {
        name: 'Indicators',
        path: model_indicators_url(@model), key: 'indicators'
      },
      {
        name: 'Scenarios',
        path: model_scenarios_url(@model), key: 'scenarios'
      }
    ]
  end

  def handle_io_upload(file_name, redirect_url)
    @uploaded_io = params[file_name]
    unless @uploaded_io.present?
      redirect_to(
        redirect_url, alert: 'Please provide an upload file'
      ) and return true
    end
    csv_upload = yield
    unless csv_upload.save
      redirect_to(
        redirect_url, alert: 'Please provide a .csv file'
      ) and return true
    end
    handle_io_upload_in_background(csv_upload)
  end

  def handle_io_upload_in_background(csv_upload)
    job = CsvUploadJob.perform_later(csv_upload.id)
    csv_upload.update_attribute(:job_id, job.job_id)
    redirect_to(
      redirect_after_upload_url(csv_upload),
      notice: 'File has been queued for processing. Please refresh.'
    )
  end

  def set_upload_errors
    return true unless params[:csv_upload_id].present?
    csv_upload = CsvUpload.find(params[:csv_upload_id])
    return true unless csv_upload.finished_at.present?
    if csv_upload.success
      redirect_to redirect_after_upload_url, notice: csv_upload.message
    else
      @upload_errors = csv_upload.errors_and_warnings
    end
  end
end
