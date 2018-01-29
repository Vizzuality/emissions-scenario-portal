module UploadService
  attr_reader :csv_upload

  def self.included(base)
    base.validate(:existence_of_headers)
  end

  def initialize(csv_upload)
    @csv_upload = csv_upload
  end

  def call
    ActiveRecord::Base.transaction do
      if valid?
        result = import
        result.failed_instances.each { |record| transcribe_errors(record) }
      end
      update_csv_upload(result)
      csv_upload
    end
  end

  private

  def csv
    return @csv if defined?(@csv)
    file = Paperclip.io_adapters.for(csv_upload.data)
    encoding = CharlockHolmes::EncodingDetector.detect(file.read)[:encoding]
    @csv = CSV.open(file.path, 'r', headers: true, encoding: encoding).read
  end

  def raw_csv_headers
    csv.headers
  end

  def parsed_csv_headers
    raw_csv_headers.map do |header|
      headers.
        transform_values(&:downcase).
        key(header.to_s.downcase.gsub(/\s+/, ' ').strip) || header
    end
  end

  def existence_of_headers
    (headers.keys - parsed_csv_headers).each do |value|
      errors.add(
        :csv_upload,
        :invalid,
        msg: "Missing header: #{value}",
        row: 1,
        type: :header
      )
    end
  end

  def transcribe_errors(record)
    record.errors.messages.each do |attribute, _|
      record.errors.full_messages_for(attribute).each.with_index do |message, i|
        errors.add(
          :csv_upload,
          message,
          row: record.row,
          col: record.respond_to?(:col) ?
            record.col : parsed_csv_headers.index(attribute) + 1,
          msg: message,
          type: :record,
          **record.errors.details[attribute][i]
        )
      end
    end
  end

  def update_csv_upload(result)
    number_of_records_failed = result&.failed_instances&.size.to_i
    number_of_records_saved = result&.ids&.size.to_i
    total_number_of_records = number_of_records_failed + number_of_records_saved

    csv_upload.update(
      success: errors.blank?,
      message: "#{number_of_records_saved} of #{total_number_of_records} records saved.",
      finished_at: Time.current,
      errors_and_warnings: {errors: errors.details[:csv_upload]},
      number_of_records_failed: number_of_records_failed,
      number_of_records_saved: number_of_records_saved
    )
  end
end
