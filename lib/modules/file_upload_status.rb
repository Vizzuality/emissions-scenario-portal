class FileUploadStatus
  attr_reader :number_of_records, :number_of_records_failed, :errors
  def initialize(number_of_records, number_of_records_failed, errors)
    @number_of_records = number_of_records
    @number_of_records_failed = number_of_records_failed
    @errors = errors
  end

  def number_of_records_saved
    number_of_records - number_of_records_failed
  end

  def no_errors?
    @number_of_records_failed.zero?
  end

  def error_type
    if errors[:type] == :headers
      :headers
    elsif errors[:type] == :columns
      :columns
    else
      :rows
    end
  end

  def errors_to_array
    rows = []
    errors.except(:type).each do |key, message_hash_or_struct|
      rows_to_append =
        if message_hash_or_struct.is_a?(Hash)
          message_hash_or_struct.values.map do |message|
            "#{key},\"#{message}\""
          end
        else
          ["#{key},\"#{message_hash_or_struct}\""]
        end
      rows += rows_to_append
    end
    rows
  end

  def errors_to_csv
    header_row = "#{error_type.to_s.singularize.capitalize}, Error"
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

  def stats_message
    "#{number_of_records_saved} of #{@number_of_records} #{error_type} saved."
  end
end
