class IndicatorsUploadTemplate
  def export
    CSV.generate do |csv|
      csv << UploadIndicators::HEADERS.values
      csv << [nil] * UploadIndicators::HEADERS.values.size
    end
  end
end
