require 'scenarios_headers'

class ScenariosData
  include CsvUploadData
  attr_reader :number_of_rows, :number_of_rows_failed, :errors

  def initialize(path, user)
    @path = path
    @user = user
    @headers = ScenariosHeaders.new(@path)
    initialize_stats
  end

  def process_row(row, row_no)
    @errors[row_no] = {}

    model = model(row, @errors[row_no])
    scenario_attributes = {
      model_id: model.try(:id)
    }.merge(
      Hash[
        Scenario.attribute_infos.reject(&:reference?).map(&:name).map do |attr|
          [attr, value_for(row, attr)]
        end
      ]
    )

    scenario = model && Scenario.where(
      model_id: model.id, name: scenario_attributes[:name]
    ).first

    scenario ||= Scenario.new
    scenario.attributes = scenario_attributes
    @errors[row_no]['scenario'] = scenario.errors unless scenario.save

    if @errors[row_no].any?
      @number_of_rows_failed += 1
    else
      @errors.delete(row_no)
    end
  end

  def value_for(row, property_name)
    value = row[@headers.actual_index_for_property(property_name)]
    if Scenario.attribute_info(property_name).multiple?
      value = value.split(';').map(&:strip) unless value.blank?
    end
    value
  end

  def model(row, errors)
    model_abbreviation = value_for(row, :model_abbreviation)
    if model_abbreviation.blank?
      errors['model'] = 'Model must be present'
      return nil
    end
    identification = "model: #{model_abbreviation}"

    models = Model.where(abbreviation: model_abbreviation)
    model = matching_object(models, 'model', identification, errors)
    return nil if model.nil?
    if @user.cannot?(:manage, model)
      errors['model'] = "Access denied: model (#{identification})"
      return nil
    end
    model
  end
end
