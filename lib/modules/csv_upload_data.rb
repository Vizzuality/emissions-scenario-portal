require 'charlock_holmes'
module CsvUploadData
  def initialize_stats
    @number_of_rows = File.foreach(@path).count - 1
    @number_of_rows_failed, @errors =
      if @headers.errors.any?
        [@number_of_rows, @headers.errors.merge(type: :headers)]
      else
        [0, {}]
      end
  end

  def process
    return if @headers.errors.any?
    detection = CharlockHolmes::EncodingDetector.detect(File.read(@path))
    CSV.open(
      @path, 'r', headers: true, encoding: detection[:encoding]
    ).each.with_index(2) do |row, row_no|
      process_row(row, row_no)
    end
  end

  def value_for(row, property_name)
    row[@headers.actual_index_for_property(property_name)]
  end

  def matching_object(object_collection, object_type, identification, errors)
    if object_collection.count > 1
      message = "More than one #{object_type} found (#{identification})."
      suggestion = 'Please resolve duplicates in the database.'
      errors[object_type] = format_error(message, suggestion)
      nil
    elsif object_collection.count.zero?
      message = "#{object_type.capitalize} does not exist (#{identification})."
      suggestion = "Please ensure the correct reference is used or add \
missing data into the system first."
      # TODO: url
      errors[object_type] = format_error(message, suggestion)
      nil
    else
      object_collection.first
    end
  end

  def model(row, errors)
    model_abbreviation = value_for(row, :model_abbreviation)
    if model_abbreviation.blank?
      message = 'Model must be present.'
      suggestion = 'Please fill in the model abbreviation.'
      errors['model'] = format_error(message, suggestion)
      return nil
    end
    identification = "model: #{model_abbreviation}"

    models = Model.where(abbreviation: model_abbreviation)
    model = matching_object(models, 'model', identification, errors)
    return nil if model.nil?
    if @user.cannot?(:manage, model)
      message = "Access denied to manage model (#{identification})."
      suggestion = 'Please verify your team\'s permissions.'
      # TODO: url
      errors['model'] = format_error(message, suggestion)
      return nil
    end
    model
  end

  def format_error(message, suggestion)
    [message, suggestion].join(' ')
  end
end
