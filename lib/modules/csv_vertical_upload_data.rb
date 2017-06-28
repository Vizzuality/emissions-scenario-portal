module CsvVerticalUploadData
  attr_reader :number_of_records, :number_of_records_failed, :errors

  def self.included(base)
    base.extend(ClassMethods)
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
    @number_of_records_failed, @errors =
      if @headers.errors.any?
        [@number_of_records, @headers.errors.merge(type: :headers)]
      else
        [0, {}]
      end
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
        message = "Unrecognised column header #{header}."
        suggestion = 'Please consult the [template] for correct structure.'
        @errors[header] = FileUploadError.new(
          message, suggestion, url: @template_url, placeholder: 'template'
        )
        {
          display_name: header
        }
      end
    end
  end

  def process
    return if @headers.errors.any?
    data = CSV.read(
      @path, 'r', headers: true, encoding: @encoding
    )
    header_column = data.map do |d|
      d[CsvVerticalUploadHeaders::ATTRIBUTE_NAME_INDEX]
    end
    parse_vertical_headers(header_column)

    if @errors.any?
      @number_of_records_failed = @number_of_records
      @errors[:type] = :columns
      return
    end
    # for each data header
    (
      @headers.static_headers.length..@headers.headers.length - 1
    ).each do |col_no|
      col = data.map { |d| d[col_no] }
      process_column(col, col_no)
    end
    @errors[:type] = :columns if @errors.any?
  end

  def value_for(col, property_name)
    value = col[actual_index_for_property(property_name)]
    if multiple_selection?(property_name)
      value = value.split(';').map(&:strip) unless value.blank?
    end
    value
  end

  def actual_index_for_property(property_name)
    expected_index = self.class::EXPECTED_PROPERTIES[property_name][:index]
    @actual_headers.index do |h|
      h[:expected_index] == expected_index
    end
  end
end
