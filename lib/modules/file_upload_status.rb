class FileUploadStatus
  attr_reader :number_of_rows, :number_of_rows_failed, :errors
  def initialize(number_of_rows, number_of_rows_failed, errors)
    @number_of_rows = number_of_rows
    @number_of_rows_failed = number_of_rows_failed
    @errors = errors
  end

  def number_of_rows_saved
    number_of_rows - number_of_rows_failed
  end

  def no_errors?
    @number_of_rows_failed.zero?
  end

  def error_type
    errors[:type] == :headers ? :headers : :rows
  end

  def errors_to_array
    rows = []
    errors.except(:type).each do |key, message_hash_or_string|
      rows_to_append =
        if message_hash_or_string.is_a?(Hash)
          message_hash_or_string.values.map do |message|
            if message.is_a?(ActiveModel::Errors)
              message = message.map { |k, v| "#{k}: #{v}" }.join(', ')
            end
            "#{key},\"#{message}\""
          end
        else
          ["#{key},\"#{message_hash_or_string}\""]
        end
      rows += rows_to_append
    end
    rows
  end

  def errors_to_csv
    header_row =
      if errors[:type] == :headers
        'Header, Error'
      else
        'Row, Error'
      end
    csv = [header_row]
    size_in_bytes = header_row.bytesize + 1
    remaining_errors = errors_to_array
    remaining_errors_cnt = remaining_errors.size
    errors_to_array.each do |row|
      if size_in_bytes + (row.bytesize + 1) +
          (remaining_errors_message(remaining_errors_cnt).bytesize + 1) < 1800
        csv << row
        size_in_bytes += (row.bytesize + 1)
        remaining_errors_cnt -= 1
      else
        csv << remaining_errors_message(remaining_errors_cnt)
        size_in_bytes += (
          remaining_errors_message(remaining_errors_cnt).bytesize + 1
        )
        break
      end
    end
    csv.join("\n")
  end

  def remaining_errors_message(error_count)
    return '' unless error_count.positive?
    ",\"#{error_count} erroneous #{error_type} suppressed\""
  end
end
