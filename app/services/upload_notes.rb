class UploadNotes
  attr_reader :csv_upload, :errors

  HEADERS = %w[
    model_name esp_indicator_name unit_of_entry conversion_factor description
  ].freeze

  def initialize(csv_upload)
    @csv_upload = csv_upload
    @errors = ActiveModel::Errors.new(self)
  end

  def call
    tap do
      validate_number_of_headers
      validate_headers

      ActiveRecord::Base.transaction do
        notes = create_notes
        update_csv_upload(notes)
      end
    end
  end

  private

  def path
    @path ||= Paperclip.io_adapters.for(csv_upload.data).path
  end

  def csv
    encoding = CharlockHolmes::EncodingDetector.detect(File.read(path))[:encoding]
    @csv ||= CSV.open(path, 'r', headers: true, encoding: encoding).read
  end

  def validate_number_of_headers
    return if HEADERS.size == csv.headers.size
    errors.add(:headers, 'Incorrect number of columns')
  end

  def normalize_header(header)
    normalized = header.to_s.downcase.strip.gsub(/\s+/, '_')
    normalized if HEADERS.include?(normalized)
  end

  def validate_headers
    remaining_headers = HEADERS.dup

    HEADERS.each do |header|
      next if remaining_headers.delete(normalize_header(header))
      errors.add(:headers, 'Invalid header')
    end

    remaining_headers.each do |header|
      errors.add(:base, 'Missing header')
    end
  end

  def create_note(attributes)
    model =
      Pundit.
        policy_scope(csv_upload.user, Model).
        find_by_name(attributes['model_name'])

    indicator =
      Indicator.
        find_by_name(attributes['esp_indicator_name'])

    Note.find_or_initialize_by(model: model, indicator: indicator).tap do |note|
      note.update(attributes.except('model_name', 'esp_indicator_name'))
    end
  end

  def create_notes
    csv.map.with_index(2) do |row, line|
      attributes =
        row.map { |header, value| [normalize_header(header), value] }.to_h

      next if attributes.all?(&:blank?)

      create_note(attributes).tap do |note|
        next if note.valid?
        note.errors.messages.each do |attribute, _|
          note.errors.full_messages_for(attribute).each.with_index do |message, i|
            errors.add(
              :notes,
              message,
              row: line,
              column: attribute,
              **note.errors.details[attribute][i]
            )
          end
        end
      end
    end
  end

  def update_csv_upload(notes)
    saved = notes.select(&:persisted?).size
    total = notes.size

    csv_upload.update(
      success: errors.present?,
      message: "#{saved} of #{total} rows saved.",
      finished_at: Time.current,
      errors_and_warnings: {
        errors: errors.details
      }
    )
  end
end
