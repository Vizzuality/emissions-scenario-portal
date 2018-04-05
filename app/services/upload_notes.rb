class UploadNotes
  include ActiveModel::Model
  include CsvParsingHelpers

  attr_reader :csv_upload

  HEADERS = {
    indicator: 'Default Indicator Name',
    model: 'Model Name',
    unit_of_entry: 'Unit of Entry',
    conversion_factor: 'Conversion Factor',
    description: 'Note'
  }.freeze

  def initialize(csv_upload)
    @csv_upload = csv_upload
  end

  def call
    if valid_headers?(HEADERS)
      rows = parse_rows
      rows = sanitize_rows(rows)
      records = build_records(rows)
    end
    perform_import(records || [])
    csv_upload
  end

  private

  def parse_rows
    csv.map.with_index(2) do |row, line_number|
      parse_headers(HEADERS).zip(row.fields).to_h.tap do |attrs|
        attrs[:model] = models[attrs[:model]] || attrs[:model]
        attrs[:indicator] = indicators[attrs[:indicator]] || attrs[:indicator]
        attrs[:row] = line_number
      end
    end
  end

  def sanitize_rows(rows)
    set = Set.new
    rows.select do |row|
      row.except(:row).values.any?(&:present?) &&
        # skip rows with missing associations
        skip_incomplete(row, :model) &&
        skip_incomplete(row, :indicator) &&
        # prevent overwriting the same records more than once
        skip_duplicate(set, row, %i[model indicator])
    end
  end

  def build_records(attrs_list)
    attrs_list.map { |attrs| Note.new(attrs.slice(*HEADERS.keys)) }
  end

  def perform_import(records)
    ActiveRecord::Base.transaction do
      result = Note.import(
        records,
        on_duplicate_key_update: {
          conflict_target: %i[indicator_id model_id],
          columns: %i[unit_of_entry conversion_factor description]
        }
      )

      csv_upload.update!(
        success: errors.blank?,
        finished_at: Time.current,
        errors_and_warnings: {errors: errors.details[:base]},
        number_of_records_saved: result.ids.size
      )
    end
  end
end
