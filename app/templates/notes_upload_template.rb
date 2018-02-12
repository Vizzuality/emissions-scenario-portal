class NotesUploadTemplate
  attr_accessor :model

  def export
    CSV.generate do |csv|
      csv << headers
      Indicator.find_each do |indicator|
        if model.present?
          note = Note.find_by(indicator: indicator, model: model)
        end

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
