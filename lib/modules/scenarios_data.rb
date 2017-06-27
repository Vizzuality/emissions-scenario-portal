require 'scenarios_headers'

class ScenariosData
  include CsvUploadData
  attr_reader :number_of_rows, :number_of_records_failed, :errors

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
    if scenario_attributes[:name].blank?
      message = 'Scenario name must be present.'
      suggestion = 'Please fill in missing data.'
      @errors[row_no]['name'] = format_error(message, suggestion)
    end

    scenario = model && Scenario.where(
      model_id: model.id, name: scenario_attributes[:name]
    ).first

    scenario ||= Scenario.new
    scenario.attributes = scenario_attributes
    process_other_errors(@errors[row_no], scenario.errors) unless scenario.save

    if @errors[row_no].any?
      @number_of_records_failed += 1
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
end
