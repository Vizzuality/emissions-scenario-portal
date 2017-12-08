class UploadNotes
  attr_reader :csv_upload, :errors

  HEADERS = %w[
    model esp_indicator_name unit_of_entry conversion_factor description
  ].freeze

  def initialize(csv_upload)
    @csv_upload = csv_upload
    @errors = ActiveModel::Errors.new(self)
  end

  def call
    ensure_correct_number_of_headers
    ensure_correct_headers
    import_notes
    self
  end

  private

  def path
    @path ||= Paperclip.io_adapters.for(csv_upload.data).path
  end

  def csv
    encoding = CharlockHolmes::EncodingDetector.detect(File.read(path))[:encoding]
    @csv ||= CSV.open(path, 'r', headers: true, encoding: encoding).read
  end

  def ensure_correct_number_of_headers
    return if HEADERS.size == csv.headers.size
    errors.add(:base, 'Incorrect number of columns')
  end

  def normalize_header(header)
    normalized = header.to_s.downcase.strip.gsub(/\s+/, '_')
    normalized if HEADERS.include?(normalized)
  end

  def ensure_correct_headers
    remaining_headers = HEADERS.dup
    HEADERS.each do |header|
      return if remaining_headers.delete(normalize_header(header))
      errors.add(:base, 'Invalid header')
    end

    remaining_headers.each do |header|
      errors.add(:base, 'Missing header')
    end
  end

  def build_note(attributes)
    model =
      Pundit.
        policy_scope(csv_upload.user, Model).
        where('lower(full_name) = ?', attributes['model'].downcase).
        first

    indicator =
      Indicator.
        where(
          'lower(composite_name) = ?',
          attributes['esp_indicator_name'].downcase
        ).
        first

    Note.find_or_initialize_by(model: model, indicator: indicator).tap do |note|
      note.attributes = attributes.except('model', 'esp_indicator_name')
    end
  end

  def import_notes
    csv.map.with_index(2) do |row, line|
      attributes =
        row.map { |header, value| [normalize_header(header), value] }.to_h
      note = build_note(attributes)
      if note.save
        puts note.inspect
      else
        puts note.inspect
        puts note.errors.inspect
        errors.add(:note, 'Invalid note')
      end
    end
  end
end
