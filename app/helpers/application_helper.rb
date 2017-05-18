module ApplicationHelper
  def attribute_name(object, attr_symbol)
    t object.key_for_name(attr_symbol)
  end

  def attribute_definition(object, attr_symbol)
    t object.key_for_definition(attr_symbol)
  end

  def attribute_input(object, form, attr_symbol)
    if (ref_symbol = object.class.reference_attribute(attr_symbol))
      reference_input(object, form, attr_symbol, ref_symbol)
    elsif object.class.date_attribute?(attr_symbol)
      date_input(form, attr_symbol)
    elsif object.class.picklist_attribute?(attr_symbol)
      picklist_input(object, form, attr_symbol)
    else
      size = object.class.size_attribute(attr_symbol)
      form.text_field attr_symbol, class: "c-input-text -#{size}"
    end
  end

  def attribute_category(object, attr_symbol)
    object.class.category_attribute(attr_symbol)
  end

  def date_input(form, attr_symbol)
    form.text_field attr_symbol, class: "TODO I'm a date selector"
  end

  def picklist_input(object, form, attr_symbol)
    size = object.class.size_attribute(attr_symbol)
    is_multiple = object.class.multiple_attribute?(attr_symbol)
    picklist_values = values_for_attribute_dropdown(
      object, attr_symbol, is_multiple
    )
    options = {prompt: 'Please select'}
    html_options = {}
    html_options[:multiple] = true if is_multiple

    content_tag :div, class: "c-select -#{size}" do
      form.select attr_symbol, picklist_values, options, html_options
    end
  end

  def reference_input(object, form, attr_symbol, ref_symbol)
    size = object.class.size_attribute(attr_symbol)
    ref_object_symbol, ref_attr_symbol = ref_symbol.split('.')
    select_values, selection = values_for_reference_dropdown(
      object, ref_object_symbol, ref_attr_symbol
    )
    options = {prompt: 'Please select'}

    content_tag :div, class: "c-select -#{size}" do
      form.select(
        ref_object_symbol + '_id',
        options_for_select(select_values, selection.try(:id)),
        options
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
end
