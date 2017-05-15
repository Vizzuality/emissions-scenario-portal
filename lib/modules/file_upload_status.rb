class FileUploadStatus
  attr_reader :number_of_rows_read, :number_of_rows_saved, :errors
  def initialize(number_of_rows_read, number_of_rows_saved, errors)
    @number_of_rows_read = number_of_rows_read
    @number_of_rows_saved = number_of_rows_saved
    @errors = errors
  end

  def number_of_rows_failed
    @number_of_rows_read - @number_of_rows_saved
  end
end
