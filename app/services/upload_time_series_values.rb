class UploadTimeSeriesValues
  include ActiveModel::Model

  HEADERS = {
    model_abbreviation: 'Model Name',
    scenario_name: 'Scenario',
    location_name: 'Region'
    indicator_name: 'ESP Indicator Name',
    unit_of_entry: 'Unit of Entry'
  }.freeze

  attr_reader :csv_upload
  validate :existence_of_headers

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

  def csv
    return @csv if defined?(@csv)
    file = Paperclip.io_adapters.for(csv_upload.data)
    encoding = CharlockHolmes::EncodingDetector.detect(file.read)[:encoding]
    @csv = CSV.open(file.path, 'r', headers: true, encoding: encoding).read
  end

  def match_header(header)
    HEADERS.
      transform_values(&:downcase).
      key(header.to_s.downcase.gsub(/\s+/, ' ').strip)
  end

  def existence_of_headers
    remaining_headers = HEADERS.dup

    csv.headers.each do |header|
      next if remaining_headers.delete(match_header(header))
      next if header =~ /\A\d{4}\Z/
      errors.add(
        :csv_upload,
        :invalid,
        msg: "Unrecognized header: #{header}",
        row: 1,
        type: :header
      )
    end

    remaining_headers.each_value do |value|
      errors.add(
        :csv_upload,
        :invalid,
        msg: "Missing header: #{value}",
        row: 1,
        type: :header
      )
    end
  end

  def create_time_series_value(attributes)
    model =
      Pundit.
        policy_scope(csv_upload.user, Model).
        find_by_abbreviation(attributes[:model_abbreviation])

    scenario = model.scenarios.find_by_name(attributes[:scenario_name])
    indicator = Indicator.find_by_name(attributes[:indicator_name])
    location = Location.find_by_name(attributes[:location_name])

    attributes.except(*%i[model_abbreviation scenario_name indicator_name location_name]).each do |year, value|
      TimeSeriesValue.build(
        scenario: scenario,
        indicator: indicator,
        location: location,
        year: year,
        value: value
      )
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
      attributes = row.map { |header, value| [match_header(header), value] }.to_h

      next if attributes.all?(&:blank?)

      create_note(attributes).tap do |note|
        transcribe_errors(note, line_number) if note.invalid?
      end
    end
  end

  def update_csv_upload(notes)
    csv_upload.update(
      success: errors.blank?,
      message: "#{notes.select(&:valid?).size} of #{csv.size} rows saved.",
      finished_at: Time.current,
      errors_and_warnings: {errors: errors.details[:csv_upload]}
    )
  end
end
