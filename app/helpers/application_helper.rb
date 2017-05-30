module ApplicationHelper
  def attribute_name(object, attr_symbol)
    t object.key_for_name(attr_symbol)
  end

  def attribute_definition(object, attr_symbol)
    t object.key_for_definition(attr_symbol)
  end

  def attribute_input(object, form, attr_symbol)
    attr_info = object.class.attribute_info(attr_symbol)
    if attr_info.reference?
      reference_input(object, form, attr_info)
    elsif attr_info.date?
      date_input(object, form, attr_info)
    elsif object.class.picklist_attribute?(attr_symbol)
      picklist_input(object, form, attr_symbol)
    else
      size = object.class.size_attribute(attr_symbol)
      form.text_field attr_symbol, class: "c-input-text -#{size} js-form-input"
    end
  end

  def attribute_category(object, attr_symbol)
    object.class.category_attribute(attr_symbol)
  end

  def date_input(object, form, attr_info)
    size = attr_info.size
    form.text_field attr_info.name, class:
      "c-input-text -#{size} js-datepicker-input js-form-input"
  end

  def picklist_input(object, form, attr_symbol)
    size = object.class.size_attribute(attr_symbol)
    is_multiple = object.class.multiple_attribute?(attr_symbol)
    picklist_values = values_for_attribute_dropdown(
      object, attr_symbol, is_multiple
    )
    options = {prompt: 'Please select'}
    html_options = {}
    html_options[:multiple] = true
    html_options[:class] = picklist_class(is_multiple)

    content_tag :div, class: "c-select -#{size}" do
      form.select attr_symbol, picklist_values, options, html_options
    end
  end

  def reference_input(object, form, attr_info)
    size = attr_info.size
    select_values, selection = values_for_reference_dropdown(
      object, attr_info.referenced_object, attr_info.referenced_attribute
    )
    options = {prompt: 'Please select'}
    html_options = {class: 'js-form-input js-select'}

    content_tag :div, class: "c-select -#{size}" do
      form.select(
        attr_info.referenced_object + '_id',
        options_for_select(select_values, selection.try(:id)),
        options,
        html_options
      )
    end
  end

  def values_for_attribute_dropdown(object, attr_symbol, is_multiple)
    picklist_values = object.class.
      distinct.order(attr_symbol).pluck(attr_symbol)
    picklist_values = picklist_values.flatten.uniq if is_multiple
    picklist_values.compact
  end

  def values_for_reference_dropdown(object, ref_object_symbol, ref_attr_symbol)
    ref_object = object.send(ref_object_symbol)
    ref_klass = ref_object_symbol.capitalize.constantize
    select_values = ref_klass.select(:id, ref_attr_symbol).map do |v|
      [v.send(ref_attr_symbol), v.id]
    end
    [select_values, ref_object]
  end

  def picklist_class(is_multiple)
    "js-form-input #{if is_multiple
                       'js-multiple-select'
                     else
                       'js-multisingle-select'
                     end}"
  end
end
