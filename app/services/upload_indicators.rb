class UploadIndicators
  include ActiveModel::Model
  include CsvParsingHelpers

  attr_reader :csv_upload

  HEADERS = {
    indicator: 'ESP Indicator Name',
    stackable: 'Stackable sub-category?',
    unit: 'Standardized Unit',
    definition: 'Definition'
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
    csv.map.with_index(2) do |csv_row, line_number|
      fields = csv_row.fields[0..(HEADERS.length - 1)]
      parse_headers(HEADERS).zip(fields).to_h.tap do |row|
        row[:indicator] = indicators[row[:indicator]] || row[:indicator]
        row[:row] = line_number
      end
    end
  end

  def parse_stackable(row)
    case row[:stackable]
    when /\A(y|yes|true|t|1)\Z/i
      row[:stackable] = true
    when /\A(n|no|false|f|0)\Z/i
      row[:stackable] = false
      true
    else
      add_error(
        :invalid_stackable,
        "Invalid stackable value #{row[:stackable]}",
        row.slice(:row)
      )
    end
  end

  def inject_subcategory_and_name(row)
    if row[:indicator].kind_of?(ApplicationRecord)
      row[:subcategory] = row[:indicator].subcategory
      row[:name] = row[:indicator].name
    end

    category_name, subcategory_name, row[:name] = row[:indicator].to_s.split('|', 3)
    row[:subcategory] = subcategories[
      [categories[category_name], subcategory_name, row[:stackable]]
    ]

    if row[:name].blank?
      return add_error(
        :missing_indicator_name,
        "Indicator name can't be blank",
        row.slice(:row)
      )
    end

    if row[:subcategory].blank?
      msg = "Category, subcategory pair has not been found #{category_name}, #{subcategory_name}"
      msg += ' (stackable)' if row[:stackable]

      return add_error(:invalid_categories, msg, row.slice(:row))
    end

    true
  end

  def sanitize_rows(rows)
    set = Set.new
    rows.select do |row|
      row.except(:row).values.any?(&:present?) &&
        parse_stackable(row) &&
        inject_subcategory_and_name(row) &&
        skip_duplicate(set, row, %i[subcategory name])
    end
  end

  def build_records(attrs_list)
    attrs_list.map do |attrs|
      Indicator.new(attrs.slice(*%i[subcategory name unit definition]))
    end
  end

  def perform_import(records)
    ActiveRecord::Base.transaction do
      result = Indicator.import(
        records,
        on_duplicate_key_update: {
          conflict_target: %i[name subcategory_id],
          columns: %i[definition unit]
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
