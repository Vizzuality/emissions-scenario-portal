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

      rows = rows.reject { |row| row.except(:row).values.all?(&:blank?) }
      rows = parse_stackable(rows)
      rows = inject_subcategory_and_name(rows)

      # prevent overwriting the same records more than once
      rows = skip_duplicate(rows, %i[subcategory name])

      records = rows.map { |row| Indicator.new(row.slice(*%i[subcategory name unit definition])) }
    end

    ActiveRecord::Base.transaction do
      result = import(records)

      csv_upload.update!(
        success: errors.blank?,
        finished_at: Time.current,
        errors_and_warnings: {errors: errors.details[:base]},
        number_of_records_saved: result.ids.size
      )
    end

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

  def parse_stackable(rows)
    rows.select do |row|
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
  end

  def inject_subcategory_and_name(rows)
    rows.select do |row|
      if row[:indicator].kind_of?(ApplicationRecord)
        row[:subcategory] = row[:indicator].subcategory
        row[:name] = row[:indicator].name
        true
      else
        category_name, subcategory_name, row[:name] = row[:indicator].to_s.split('|', 3)
        row[:subcategory] = subcategories[
          [categories[category_name], subcategory_name, row[:stackable]]
        ]
        if row[:name].blank?
          add_error(
            :missing_indicator_name,
            "Indicator name can't be blank",
            row.slice(:row)
          )
        elsif row[:subcategory].blank?
          msg = "Category, subcategory pair has not been found #{category_name}, #{subcategory_name}"
          msg += ' (stackable)' if row[:stackable]

          add_error(:invalid_categories, msg, row.slice(:row))
        else
          true
        end
      end
    end
  end

  def import(records)
    Indicator.import(
      records || [],
      on_duplicate_key_update: {
        conflict_target: %i[name subcategory_id],
        columns: %i[definition unit]
      }
    )
  end
end
