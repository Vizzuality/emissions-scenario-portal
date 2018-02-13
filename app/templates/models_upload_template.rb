class ModelsUploadTemplate
  attr_accessor :user

  def export
    CSV.generate do |csv|
      csv << headers
      ModelsData::PROPERTY_NAMES.each do |property_name|
        attr_info = Model.attribute_info(property_name)

        csv << [
          attr_info.category,
          I18n.t(Model.key_for_name(property_name)),
          I18n.t(Model.key_for_definition(property_name)),
          attr_info.input_type_for_display,
          attr_info.options.try(:join, '; ')
        ] + models_attributes(attr_info.name)
      end
    end
  end

  private

  def models
    Pundit.policy_scope(user, Model)
  end

  def headers
    base_headers = [
      'Category', 'Indicator', 'Definition/Input Explanation', 'Data Type',
      'Picklist options (Data Entry)'
    ]

    models_headers =
      if models.present?
        models.map.with_index(1) { |_, i| "Model #{i}" }
      else
        ['Model 1']
      end

    base_headers + models_headers
  end

  def models_attributes(attribute_name)
    if models.present?
      models.map do |model|
        attribute = model[attribute_name]
        attribute.respond_to?(:join) ? attribute.join('; ') : attribute
      end
    else
      [nil]
    end
  end
end
