class UploadNotes
  include ActiveModel::Model

  HEADERS = %w[
    model_name esp_indicator_name unit_of_entry conversion_factor description
  ].freeze

  attr_reader :csv_upload
  validate :number_of_headers, :existence_of_headers

  def initialize(csv_upload)
    @csv_upload = csv_upload
  end

  def call
    ActiveRecord::Base.transaction do
      notes = create_notes if valid?
      update_csv_upload(notes || [])
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

  def number_of_headers
    return if HEADERS.size == csv.headers.size
    errors.add(
      :csv_upload,
      :invalid,
      msg: 'Invalid number of columns',
      row: 1,
      type: :header
    )
  end

  def normalize_header(header)
    normalized = header.to_s.downcase.strip.gsub(/\s+/, '_')
    normalized if HEADERS.include?(normalized)
  end

  def existence_of_headers
    remaining_headers = HEADERS.dup

    csv.headers.each do |header|
      next if remaining_headers.delete(normalize_header(header))
      errors.add(
        :csv_upload,
        :invalid,
        msg: "Invalid header: #{header}",
        row: 1,
        type: :header
      )
    end

    remaining_headers.each do |header|
      errors.add(
        :csv_upload,
        :invalid,
        msg: "Missing header: #{header.titleize}",
        row: 1,
        type: :header
      )
    end
  end

  def create_note(attributes)
    model = Pundit.
        policy_scope(csv_upload.user, Model).
        find_by_name(attributes['model_name'])

    indicator = Indicator.find_by_name(attributes['esp_indicator_name'])

    Note.find_or_initialize_by(model: model, indicator: indicator).tap do |note|
      note.update(attributes.except('model_name', 'esp_indicator_name'))
    end
  end

  def transcribe_errors(note, row)
    note.errors.messages.each do |attribute, _|
      note.errors.full_messages_for(attribute).each.with_index do |message, i|
        errors.add(
          :csv_upload,
          message,
          row: row,
          col: attribute,
          msg: message,
          type: :note,
          **note.errors.details[attribute][i]
        )
      end
    end
  end

  def create_notes
    csv.map.with_index(2) do |row, line_number|
      attributes =
        row.map { |header, value| [normalize_header(header), value] }.to_h

      next if attributes.all?(&:blank?)

      create_note(attributes).tap do |note|
        transcribe_errors(note, line_number) if note.invalid?
      end
    end
  end

  def update_csv_upload(notes)
    csv_upload.update(
      success: errors.present?,
      message: "#{notes.select(&:valid?).size} of #{csv.size} rows saved.",
      finished_at: Time.current,
      errors_and_warnings: {errors: errors.details[:csv_upload]}
    )
  end
end
