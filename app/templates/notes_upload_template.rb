class NotesUploadTemplate
  def export
    CSV.generate do |csv|
      csv << headers
      Indicator.pluck(:composite_name).each do |name|
        csv << [name] + [nil] * (headers.size - 1)
      end
    end
  end

  private

  def headers
    UploadNotes::HEADERS.values
  end
end
