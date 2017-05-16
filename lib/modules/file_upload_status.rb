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
end
