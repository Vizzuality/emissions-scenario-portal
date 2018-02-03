class TimeSeriesValuesUploadTemplate
  def export
    years = %w(2005 2010 2020 2030 2040 2050 2060 2070 2080 2090 2100)
    headers = UploadTimeSeriesValues::HEADERS.values
    CSV.generate do |csv|
      csv << headers + years
      csv << [nil] * (headers.length + years.length)
    end
  end
end
