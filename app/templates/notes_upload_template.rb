class NotesUploadTemplate
  def export
    CSV.generate do |csv|
      csv << UploadNotes::HEADERS.values
      csv << Array.new(headers.size)
    end
  end
end
