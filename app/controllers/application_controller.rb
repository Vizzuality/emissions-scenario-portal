class ApplicationController < ActionController::Base
  include Pundit

  protect_from_forgery with: :exception
  before_action :authenticate_user!, :fetch_upload_errors

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

  def fetch_upload_errors
    return if params[:csv_upload_id].blank?
    csv_upload = CsvUpload.finished.find(params[:csv_upload_id])
    if csv_upload.success
      flash[:notice] = csv_upload.message
    else
      flash[:upload_errors] = csv_upload.errors_and_warnings
    end
    redirect_to(url_for)
  rescue ActiveRecord::RecordNotFound
  end
end
