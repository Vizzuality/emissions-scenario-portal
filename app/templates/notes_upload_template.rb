class NotesUploadTemplate
  def export
    CSV.generate do |csv|
      csv << headers
      csv << Array.new(headers.size)
    end
  end

  private

  def headers
    UploadNotes::HEADERS.values
  end
end
