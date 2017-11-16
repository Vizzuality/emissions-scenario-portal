class CsvUpload < ApplicationRecord
  belongs_to :user
  belongs_to :model, optional: true
  has_attached_file(
    :data,
    path: "#{Rails.env}/:class/:id/:filename",
  )
  validates_attachment_content_type(
    :data,
    content_type: ['text/csv', 'text/plain']
  )
  UPLOAD_SERVICES = %w(
    UploadModels UploadIndicators UploadScenarios UploadTimeSeriesValues
  ).freeze
  validates :service_type, presence: true, inclusion: {
    in: UPLOAD_SERVICES,
    message: 'must be one of ' + UPLOAD_SERVICES.join(', '),
    if: proc { |u| u.service_type.present? }
  }
end
