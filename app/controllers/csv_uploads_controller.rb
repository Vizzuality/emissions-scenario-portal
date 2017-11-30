class CsvUploadsController < ApplicationController
  def create
    csv_upload = current_user.csv_uploads.build(csv_upload_params)
    authorize(csv_upload)
    if csv_upload.save
      job = CsvUploadJob.perform_later(csv_upload.id)
      csv_upload.update!(job_id: job.job_id)
      redirect_to(
        return_path(csv_upload_id: csv_upload.id),
        notice: 'File has been queued for processing. Please refresh.'
      )
    else
      redirect_to(
        return_path,
        alert: csv_upload.errors.full_messages.join(', ')
      )
    end
  end

  private

  def csv_upload_params
    params.require(:csv_upload).permit(:model_id, :service_type, :data)
  end

  def return_path(csv_upload_id: nil)
    uri = URI.parse(params[:return_path])
    if csv_upload_id.present?
      new_query = URI.decode_www_form(uri.query.to_s)
      new_query += [["csv_upload_id", csv_upload_id]]
      uri.query = URI.encode_www_form(new_query)
    end
    uri.to_s
  end
end
