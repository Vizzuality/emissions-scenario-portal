require 'models_headers'

class ModelsData
  include CsvUploadData
  attr_reader :number_of_rows, :number_of_rows_failed, :errors

  def initialize(path, user)
    @path = path
    @user = user
    @headers = ModelsHeaders.new(@path)
    initialize_stats
  end

  def process_row(row, row_no)
    @errors[row_no] = {}

    model_attributes =
      Hash[
        Model.attribute_infos.map(&:name).map do |attr|
          [attr, value_for(row, attr)]
        end
      ]
    if model_attributes[:abbreviation].blank?
      message = 'Model abbreviation must be present.'
      suggestion = 'Please fill in missing data.'
      @errors[row_no]['name'] = format_error(message, suggestion)
    end

    model = Model.where(
      abbreviation: model_attributes[:abbreviation]
    ).first

    if model && @user.cannot?(:manage, model)
      message = "Access denied to manage model (#{model.abbreviation})."
      suggestion = 'Please verify your team\'s permissions [here].'
      @errors[row_no]['model'] = format_error(
        message,
        suggestion,
        url: url_helpers.team_path(@user.team),
        placeholder: 'here'
      )
    end

    model ||= Model.new
    model.attributes = model_attributes
    process_other_errors(@errors[row_no], model.errors) unless model.save

    if @errors[row_no].any?
      @number_of_rows_failed += 1
    else
      @errors.delete(row_no)
    end
  end

  def value_for(row, property_name)
    value = row[@headers.actual_index_for_property(property_name)]
    if Model.attribute_info(property_name).multiple?
      value = value.split(';').map(&:strip) unless value.blank?
    end
    value
  end
end
