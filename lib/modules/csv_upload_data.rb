require 'charlock_holmes'
require 'file_upload_error'

module CsvUploadData
  delegate :url_helpers, to: 'Rails.application.routes'

  def initialize_stats
    unless @encoding
      encoding_detection = CharlockHolmes::EncodingDetector.detect(
        File.read(@path)
      )
      @encoding = encoding_detection[:encoding]
    end
    @number_of_records = CSV.open(
      @path, 'r', headers: true, encoding: @encoding, &:count
    )
    initialize_errors
  end

  def initialize_errors
    @number_of_records_failed, @errors =
      if @headers.errors.any?
        [@number_of_records, @headers.errors.merge(type: :headers)]
      else
        [0, {}]
      end
  end

  def process
    return if @headers.errors.any?
    CSV.open(
      @path, 'r', headers: true, encoding: @encoding
    ).each.with_index(2) do |row, row_no|
      process_row(row, row_no)
    end
    @errors[:type] = :rows if @errors.any?
  end

  def value_for(row, property_name)
    row[@headers.actual_index_for_property(property_name)]
  end

  def matching_object(
    object_collection, object_type, identification, errors, link
  )
    link_options = {url: link, placeholder: 'here'}
    if object_collection.count > 1
      message = "More than one #{object_type} found (#{identification})."
      suggestion = 'Please resolve duplicates in the database [here].'
      errors[object_type] = format_error(
        message, suggestion, link_options
      )
      nil
    elsif object_collection.count.zero?
      message = "#{object_type.capitalize} does not exist (#{identification})."
      suggestion = "Please ensure the correct reference is used or add \
missing data into the system [here]."
      errors[object_type] = format_error(
        message, suggestion, link_options
      )
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
    model = matching_object(
      models, 'model', identification, errors, url_helpers.models_path
    )
    return nil if model.nil?
    if @user.cannot?(:manage, model)
      message = "Access denied to manage model (#{identification})."
      suggestion = 'Please verify your team\'s permissions [here].'
      errors['model'] = format_error(
        message,
        suggestion,
        url: url_helpers.team_path(@user.team),
        placeholder: 'here'
      )
      return nil
    end
    model
  end

  def format_error(message, suggestion, link_options = nil)
    FileUploadError.new(
      message,
      suggestion,
      link_options
    )
  end

  def process_other_errors(row_errors, object_errors)
    object_errors.each do |key, value|
      next if row_errors.key?(key.to_s)
      row_errors[key] = "#{key.capitalize} #{value}."
    end
  end
end
