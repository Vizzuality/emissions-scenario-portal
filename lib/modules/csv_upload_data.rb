require 'file_upload_error'

module CsvUploadData
  delegate :url_helpers, to: 'Rails.application.routes'
  attr_reader :number_of_records, :error_type

  def self.included(base)
    base.class_eval do
      include CsvUploadErrors
    end
  end

  def initialize_stats
    @number_of_records = CSV.open(
      @path, 'r', headers: true, encoding: @encoding, &:count
    )
    @error_type = :rows
    initialize_errors
  end

  def initialize_errors
    if @headers.errors?
      @error_type = :headers
      @fus = FileUploadStatus.new(
        :headers, @number_of_records, @number_of_records, @headers.errors
      )
    else
      @fus = FileUploadStatus.new(
        @error_type, @number_of_records, 0
      )
    end
  end

  def process
    return @fus if @headers.errors?
    CSV.open(
      @path, 'r', headers: true, encoding: @encoding
    ).each.with_index(2) do |row, row_no|
      process_row(row, row_no)
    end
    @fus
  end

  def value_for(row, property_name)
    index = @headers.actual_index_for_property(property_name)
    return nil unless index
    row[index]
  end

  def matching_object(
    object_collection, object_type, identification, row_no, link
  )
    link_options = {url: link, placeholder: 'here'}
    if object_collection.count > 1
      message = "More than one #{object_type} found (#{identification})."
      suggestion = 'Please resolve duplicates in the database [here].'
      @fus.add_error(
        row_no, object_type, format_error(message, suggestion, link_options)
      )
      nil
    elsif object_collection.count.zero?
      message = "#{object_type.capitalize} does not exist (#{identification})."
      suggestion = "Please ensure the correct reference is used or add \
missing data into the system [here]."
      @fus.add_error(
        row_no, object_type, format_error(message, suggestion, link_options)
      )
      nil
    else
      object_collection.first
    end
  end

  def model(row, row_no)
    model_abbreviation = value_for(row, :model_abbreviation)
    if model_abbreviation.blank?
      message = 'Model must be present.'
      suggestion = 'Please fill in the model abbreviation.'
      @fus.add_error(row_no, 'model', format_error(message, suggestion))
      return nil
    end
    identification = "model: #{model_abbreviation}"

    models = Model.where(abbreviation: model_abbreviation)
    model = matching_object(
      models, 'model', identification, row_no, url_helpers.models_path
    )
    return nil if model.nil?
    if @user.cannot?(:manage, model)
      message = "Access denied to manage model (#{identification})."
      suggestion = 'Please verify your team\'s permissions [here].'
      link_options = {
        url: url_helpers.team_path(@user.team), placeholder: 'here'
      }
      @fus.add_error(
        row_no, 'model', format_error(message, suggestion, link_options)
      )
      return nil
    end
    model
  end

  def process_other_errors(row_or_col_no, object_errors)
    object_errors.each do |key, value|
      next if @fus.errors_for_key?(row_or_col_no, key.to_s)
      @fus.add_error(
        row_or_col_no, key, format_error("#{key.capitalize} #{value}.", nil)
      )
    end
  end
end
