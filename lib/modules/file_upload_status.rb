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

  def errors_to_hash
    error_count = errors.except(:type).keys.uniq.length
    result = {
      title: "Errors found in #{error_count} #{error_type}"
    }
    rows = []
    errors.except(:type).each do |key, message_hash_or_struct|
      rows_to_append =
        if message_hash_or_struct.is_a?(Hash)
          message_hash_or_struct.values.map do |struct|
            {
              loc: key,
              message: struct.message,
              suggestion: struct.suggestion
            }
          end
        else
          [
            {
              loc: key,
              message: message_hash_or_struct.message,
              suggestion: message_hash_or_struct.suggestion
            }
          ]
        end
      rows += rows_to_append
    end
    result[:errors] = rows
    result
  end

  def stats_message
    "#{number_of_records_saved} of #{@number_of_records} #{error_type} saved."
  end
end
