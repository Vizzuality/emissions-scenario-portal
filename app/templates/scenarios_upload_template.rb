class ScenariosUploadTemplate
  attr_accessor :model

  def export
    CSV.generate do |csv|
      csv << headers
      ScenariosData::PROPERTY_NAMES.each do |property_name|
        attr_info = Scenario.attribute_info(property_name)

        csv << [
          attr_info.category,
          I18n.t(Scenario.key_for_name(property_name)),
          I18n.t(Scenario.key_for_definition(property_name)),
          attr_info.input_type_for_display,
          attr_info.options.try(:join, '; '),
        ] + scenario_attributes(attr_info.name)
      end
    end
  end

  private

  def headers
    base_headers = [
      'Category', 'Indicator', 'Definition/Input Explanation', 'Data Type',
      'Picklist options (Data Entry)'
    ]

    if model.present?
      scenarios_headers =
        model.scenarios.map.with_index(1) { |_, i| "Scenario #{i}" }
    else
      scenarios_headers = ['Scenario 1']
    end

    base_headers + scenarios_headers
  end

  def scenario_attributes(attribute_name)
    if model.present?
      model.scenarios.map do |scenario|
        result = scenario[attribute_name]
        result.respond_to?(:join) ? result.join('; ') : result
      end
    else
      [nil]
    end
  end
end
