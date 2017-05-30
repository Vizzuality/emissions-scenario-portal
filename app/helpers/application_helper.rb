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
    elsif attr_info.picklist?
      picklist_input(object, form, attr_info)
    elsif attr_info.checkbox?
      form.check_box attr_info.name, class: 'js-form-input'
    else
      text_input(object, form, attr_info)
    end
  end

  def text_input(_object, form, attr_info)
    size = attr_info.size
    form.text_field(
      attr_info.name,
      class: "c-input-text -#{size} js-form-input"
    )
  end

  def date_input(_object, form, attr_info)
    size = attr_info.size
    form.text_field attr_info.name, class:
      "c-input-text -#{size} js-datepicker-input js-form-input"
  end

  def picklist_input(object, form, attr_info)
    size = attr_info.size
    is_multiple = attr_info.multiple?
    picklist_values = values_for_attribute_dropdown(
      object, attr_info
    )
    options = {prompt: 'Please select'}
    html_options = {}
    html_options[:multiple] = true
    html_options[:class] = picklist_class(is_multiple)

    content_tag :div, class: "c-select -#{size}" do
      form.select attr_info.name, picklist_values, options, html_options
    end
  end

  def reference_input(object, form, attr_info)
    size = attr_info.size
    select_values, selection = values_for_reference_dropdown(
      object, attr_info
    )
    options = {prompt: 'Please select'}
    html_options = {class: 'js-form-input js-select'}

    content_tag :div, class: "c-select -#{size}" do
      form.select(
        attr_info.ref_object_symbol + '_id',
        options_for_select(select_values, selection.try(:id)),
        options,
        html_options
      )
    end
  end

  def values_for_attribute_dropdown(object, attr_info)
    picklist_values = object.class.
      distinct.order(attr_info.name).pluck(attr_info.name)
    picklist_values = picklist_values.flatten.uniq if attr_info.multiple?
    picklist_values.compact
  end

  def values_for_reference_dropdown(object, attr_info)
    ref_object = object.send(attr_info.ref_object_symbol)
    ref_klass = attr_info.ref_object_symbol.capitalize.constantize
    select_values = ref_klass.select(:id, attr_info.ref_attr_symbol).map do |v|
      [v.send(attr_info.ref_attr_symbol), v.id]
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
