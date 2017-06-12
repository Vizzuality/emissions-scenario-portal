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

  def errors_to_csv
    csv =
      if errors[:type] == :headers
        ['Header, Error']
      else
        ['Row, Error']
      end
    errors.except(:type).each do |key, message_hash_or_string|
      if message_hash_or_string.is_a?(Hash)
        message_hash_or_string.values.each do |message|
          if message.is_a?(ActiveModel::Errors)
            message = message.map { |k, v| "#{k}: #{v}" }.join(', ')
          end
          csv << "#{key},\"#{message}\""
        end
      else
        csv << "#{key},\"#{message_hash_or_string}\""
      end
    end
    csv.join("\n")
  end
end
