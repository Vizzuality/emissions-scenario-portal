class UploadNotes
  include ActiveModel::Model
  include UploadService

  def self.headers
    {
      model: 'Model Name',
      indicator: 'ESP Indicator Name',
      unit_of_entry: 'Unit of Entry',
      conversion_factor: 'Conversion Factor',
      description: 'Note'
    }
  end

  private

  def import
    records = csv.map.with_index(2) do |row, line_number|
      attributes = parsed_csv_headers.zip(row.fields).to_h

      next if attributes.all?(&:blank?)

      attributes[:model] = find_model(attributes[:model])
      attributes[:indicator] = find_indicator(attributes[:indicator])

      Note.new(attributes) do |note|
        note.define_singleton_method(:row) { line_number }
      end
    end

    Note.import(
      records,
      on_duplicate_key_update: {
        conflict_target: %i[indicator_id model_id],
        columns: %i[unit_of_entry conversion_factor description]
      }
    )
  end

  def find_model(model_abbreviation)
    Pundit.
      policy_scope(csv_upload.user, Model).
      find_by_abbreviation(model_abbreviation)
  end

  def find_indicator(indicator_name)
    Indicator.find_by_name(indicator_name)
  end
end
