class ApplicationController < ActionController::Base
  include Pundit

  protect_from_forgery with: :exception
  before_action :authenticate_user!, :fetch_csv_upload

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

  def fetch_csv_upload
    if params[:csv_upload_id].present?
      @csv_upload = CsvUpload.finished.find(params[:csv_upload_id])
      if @csv_upload.success
        flash[:notice] = @csv_upload.message
      else
        flash[:csv_upload_id] = @csv_upload.id
      end
      redirect_to(url_for)
    elsif flash[:csv_upload_id].present?
      @csv_upload = CsvUpload.finished.find(flash[:csv_upload_id])
    end
  rescue ActiveRecord::RecordNotFound
  end
end
