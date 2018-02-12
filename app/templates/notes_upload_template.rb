class NotesUploadTemplate
  attr_accessor :model

  def export
    CSV.generate do |csv|
      csv << headers
      model&.indicators&.each do |indicator|
        note = Note.find_by(indicator: indicator, model: model)
        csv << [
          indicator.composite_name,
          model.abbreviation,
          note&.unit_of_entry,
          note&.conversion_factor,
          note&.description
        ]
      end
    end
  end

  private

  def headers
    UploadNotes::HEADERS.values
  end
end
