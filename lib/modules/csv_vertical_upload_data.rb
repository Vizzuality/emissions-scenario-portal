require 'csv_upload_helpers'

module CsvVerticalUploadData
  attr_reader :number_of_records, :error_type

  def self.included(base)
    base.extend(ClassMethods)
    base.class_eval do
      include CsvUploadHelpers
    end
  end

  module ClassMethods
    def build_properties(property_names)
      Hash[
        property_names.map.with_index do |property_name, index|
          details = {
            display_name: I18n.t(self::DATA_CLASS.key_for_name(property_name)),
            property_name: property_name,
            index: index
          }
          [property_name, details]
        end
      ]
    end
  end

  def initialize_stats
    @number_of_records = @headers.data_headers &&
      @headers.data_headers.length || 0
    @error_type = :columns
    initialize_errors
  end

  def parse_vertical_headers(header_column)
    expected_headers_stripped =
      self.class::EXPECTED_PROPERTIES.values.map do |details|
        details[:display_name].downcase.gsub(/[^a-z0-9]/i, '')
      end
    @actual_headers = header_column.map do |header|
      stripped = header.downcase.gsub(/[^a-z0-9]/i, '')
      expected_index = expected_headers_stripped.index(stripped)
      if expected_index.present?
        {
          display_name: header,
          expected_index: expected_index
        }
      else
        unrecognised_header_error(@template_url, header, nil)
        {
          display_name: header
        }
      end
    end
  end

  def process
    return @fus if @headers.errors?
    data = CSV.read(
      @path, 'r', headers: true, encoding: @encoding
    )
    header_column = data.map do |d|
      d[CsvVerticalUploadHeaders::ATTRIBUTE_NAME_INDEX]
    end
    parse_vertical_headers(header_column)

    if errors?
      @fus.mark_all_records_failed
      return @fus
    end
    # for each data header
    (
      @headers.static_headers.length..@headers.headers.length - 1
    ).each do |col_no|
      col = data.map { |d| d[col_no] }
      process_column(col, col_no)
    end
    @fus
  end

  def value_for(col, property_name)
    index = actual_index_for_property(property_name)
    return nil unless index
    value = col[index]
    if multiple_selection?(property_name)
      value = value.present? && value.split(';').map(&:strip) || []
    end
    value
  end
end
