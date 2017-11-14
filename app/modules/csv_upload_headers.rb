require 'csv'

module CsvUploadHeaders
  delegate :url_helpers, to: 'Rails.application.routes'

  def self.included(base)
    base.class_eval do
      include CsvUploadHelpers
      include CsvUploadErrors
    end
  end

  def initialize_headers(path)
    @headers = CSV.open(path, 'r', encoding: @encoding) do |csv|
      headers = csv.first
      break [] unless headers.present?
      # detect any blank columns to the right which might ruin the parsing
      blank_columns_to_the_right = headers.reverse.inject(0) do |memo, obj|
        break memo unless obj.blank?
        memo + 1
      end
      break headers[0..(headers.length - blank_columns_to_the_right - 1)]
    end.map(&:downcase)
  end
end
