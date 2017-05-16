module ApplicationHelper
  def attribute_name(object, attribute_symbol)
    t object.key_for_name(attribute_symbol)
  end

  def attribute_definition(object, attribute_symbol)
    t object.key_for_definition(attribute_symbol)
  end

  def attribute_input(object, form, attribute_symbol)
    if object.class.picklist_attribute?(attribute_symbol)
      picklist_input(object, form, attribute_symbol)
    else
      size = object.class.size_attribute(attribute_symbol)
      form.text_field attribute_symbol, class: "c-input-text -#{size}"
    end
  end

  def attribute_category(object, attribute_symbol)
    object.class.category_attribute(attribute_symbol)
  end

  def picklist_input(object, form, attribute_symbol)
    size = object.class.size_attribute(attribute_symbol)
    is_multiple = object.class.multiple_attribute?(attribute_symbol)
    picklist_values = object.class.
      distinct.order(attribute_symbol).pluck(attribute_symbol)
    picklist_values = picklist_values.flatten.uniq if is_multiple
    picklist_values = picklist_values.compact
    options = {prompt: 'Please select'}
    html_options = {}
    html_options[:multiple] = true if is_multiple
    form.select attribute_symbol, picklist_values, options, html_options

    content_tag :div, class: "c-select -#{size}" do
      form.select attribute_symbol, picklist_values, options, html_options
    end
  end
end
