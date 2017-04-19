module ModelsHelper
  def attribute_name(attribute_symbol)
    t @model.key_for_name(attribute_symbol)
  end

  def attribute_definition(attribute_symbol)
    t @model.key_for_definition(attribute_symbol)
  end

  def attribute_input(form, attribute_symbol)
    if Model.is_picklist_attribute?(attribute_symbol)
      is_multiple = Model.is_multiple_attribute?(attribute_symbol)
      picklist_values = Model.
        distinct.order(attribute_symbol).pluck(attribute_symbol)
      if is_multiple
        picklist_values = picklist_values.flatten.uniq
      end
      picklist_values = picklist_values.compact
      options = {prompt: 'Please select'}
      html_options = {}
      html_options[:multiple] = true if is_multiple
      form.select attribute_symbol, picklist_values, options, html_options
    else
      form.text_field attribute_symbol
    end
  end
end
