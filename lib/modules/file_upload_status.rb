class FileUploadStatus
  attr_reader :number_of_records, :number_of_records_failed, :errors

  def initialize(
    error_type, number_of_records, number_of_records_failed, errors = nil
  )
    @error_type = error_type
    @number_of_records = number_of_records
    @number_of_records_failed = number_of_records_failed
    @errors = errors || {}
    @warnings = {}
  end

  def init_errors_for_row_or_col(row_or_col_no)
    @errors[row_or_col_no] = {}
    @warnings[row_or_col_no] = {}
  end

  def increment_number_of_records_failed
    @number_of_records_failed += 1
  end

  def mark_all_records_failed
    @number_of_records_failed = @number_of_records
  end

  def errors?
    @errors.any?
  end

  def warnings?
    @warnings.any?
  end

  def errors_for_row_or_col?(row_or_col_no)
    @errors[row_or_col_no].any?
  end

  def errors_for_key?(row_or_col_no, key)
    @errors[row_or_col_no][key].present?
  end

  def add_header_error(key, error)
    @errors[key] = error
  end

  def add_error(row_or_col_no, key, error)
    @errors[row_or_col_no][key] = error
  end

  def add_warning(row_or_col_no, key, warning)
    @warnings[row_or_col_no][key] = warning
  end

  def clear_errors(row_or_col_no)
    @errors.delete(row_or_col_no)
  end

  def number_of_records_saved
    number_of_records - number_of_records_failed
  end

  def no_errors_or_warnings?
    !errors? && !warnings?
  end

  def to_hash
    error_count = @errors.keys.uniq.length
    warning_count = @warnings.keys.uniq.length
    title =
      if error_count.positive?
        "Errors found in #{error_count} #{@error_type}"
      elsif warning_count.positive?
        "Warning in #{warning_count} #{@error_type}"
      end
    result = {title: title}
    result[:errors] = errors_to_hash(@errors)
    result[:warnings] = errors_to_hash(@warnings)
    result
  end

  def errors_to_hash(errors)
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
    rows
  end

  def stats_message
    "#{number_of_records_saved} of #{@number_of_records} #{@error_type} saved."
  end
end
