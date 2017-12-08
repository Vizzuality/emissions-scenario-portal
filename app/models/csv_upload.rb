class CsvUpload < ApplicationRecord
  UPLOAD_SERVICES = %w[
    UploadModels UploadIndicators UploadScenarios
    UploadTimeSeriesValues UploadNotes
  ].freeze

  belongs_to :user
  belongs_to :model, optional: true

  has_attached_file(
    :data,
    path: "#{Rails.env}/:class/:id/:filename",
  )

  validates_attachment(
    :data,
    presence: true,
    content_type: {content_type: %w[text/csv text/plain]}
  )

  validates(
    :service_type,
    inclusion: {
      in: UPLOAD_SERVICES,
      message: 'must be one of ' + UPLOAD_SERVICES.join(', ')
    }
  )

  scope :finished, -> { where.not(finished_at: nil) }
end
