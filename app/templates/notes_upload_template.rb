class NotesUploadTemplate
  def export
    CSV.generate do |csv|
      csv << UploadNotes::HEADERS.values
      csv << [nil] * UploadNotes::HEADERS.values.size
    end
  end
end
