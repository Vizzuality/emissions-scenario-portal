class CsvUploadWorker
  include Sidekiq::Worker

  def perform(csv_upload_id)
    begin
      csv_upload = CsvUpload.find(csv_upload_id)
    rescue ActiveRecord::RecordNotFound
      logger.error 'Requested CSV upload not found. Abort processing.'
      return
    end
    begin
      service_class = csv_upload.service_type.constantize
    rescue NameError
      logger.error "Service class #{csv_upload.service_type} not found. Abort \
processing."
      return
    end
    fus = service_class.new(csv_upload).call
    store_results(csv_upload, fus)
  end

  def store_results(csv_upload, fus)
    csv_upload.finished_at = Time.now
    csv_upload.success = !fus.errors?
    csv_upload.message = fus.stats_message
    unless fus.no_errors_or_warnings?
      csv_upload.errors_and_warnings = fus.to_hash
    end
    csv_upload.save
  end
end
