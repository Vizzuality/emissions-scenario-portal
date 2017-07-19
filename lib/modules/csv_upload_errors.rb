module CsvUploadErrors
  def add_header_error(key, error)
    @errors[key] = error
  end

  def add_error(row_or_col_no, key, error)
    @errors[row_or_col_no][key] = error
  end

  def clear_errors(row_or_col_no)
    @errors.delete(row_or_col_no)
  end

  def init_errors(errors = nil)
    @errors = errors || {}
  end

  def init_errors_for_row_or_col(row_or_col_no)
    @errors[row_or_col_no] = {}
  end

  def errors?
    @errors.any?
  end

  def errors_for_row_or_col?(row_or_col_no)
    @errors[row_or_col_no].any?
  end

  def errors_for_key?(row_or_col_no, key)
    @errors[row_or_col_no][key].present?
  end

  def format_error(message, suggestion, link_options = nil)
    FileUploadError.new(
      message,
      suggestion,
      link_options
    )
  end
end
