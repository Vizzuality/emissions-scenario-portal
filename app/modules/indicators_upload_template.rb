class IndicatorsUploadTemplate
  def export
    CSV.generate do |csv|
      csv << headers
      csv << Array.new(headers.length)
    end
  end

  def headers
    IndicatorsHeaders::EXPECTED_HEADERS.map do |property|
      property[:display_name]
    end
  end
end
