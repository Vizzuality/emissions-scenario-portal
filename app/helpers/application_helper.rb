module ApplicationHelper
  def attribute_name(object, attr_symbol)
    t object.class.key_for_name(attr_symbol)
  end

  def attribute_definition(object, attr_symbol)
    t object.class.key_for_definition(attr_symbol)
  end

  def attribute_input(object, form, attr_symbol)
    attr_info = object.class.attribute_info(attr_symbol)
    if attr_info.reference?
      reference_input(object, form, attr_info)
    elsif attr_info.picklist?
      picklist_input(object, form, attr_info)
    elsif attr_info.checkbox?
      checkbox_input(object, form, attr_info)
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

  def picklist_input(object, form, attr_info)
    size = attr_info.size
    is_multiple = attr_info.multiple?
    picklist_values = values_for_attribute_dropdown(
      object, attr_info
    )
    options = {}
    html_options = {}
    html_options[:multiple] = true
    html_options[:class] = picklist_class(is_multiple)
    html_options['data-placeholder'] = 'Select or add elements'

    content_tag :div, class: "c-select -#{size}" do
      form.select attr_info.name, picklist_values, options, html_options
    end
  end

  def reference_input(object, form, attr_info)
    select_values, selection, disabled =
      values_for_reference_dropdown(object, attr_info)
    options = (attr_info.options && attr_info.options.symbolize_keys) ||
      {prompt: 'Select element'}
    html_options = {class: 'js-select', disabled: disabled}
    object_method = attr_info.ref_object_symbol + '_id'
    content_tag :div, class: "c-select -#{attr_info.size}" do
      concat form.select(
        object_method,
        options_for_select(select_values, selection.try(:id)),
        options,
        html_options
      )
      concat form.hidden_field(object_method) if disabled
    end
  end

  def values_for_reference_dropdown(object, attr_info)
    object_name = object.class.to_s.downcase
    attr_name = attr_info.ref_object_symbol
    send(:"values_for_#{object_name}_#{attr_name}_dropdown", object)
  end

  def checkbox_input(_object, form, attr_info)
    content_tag :div, class: 'c-checkbox' do
      concat((form.check_box attr_info.name))
      concat(form.label(attr_info.name, '') do
        content_tag :div, class: 'c-checkbox__box' do
          svg('icon-checkbox-off') + svg('icon-checkbox-on')
        end
      end)
    end
  end

  def svg(id)
    content_tag(
      :svg,
      content_tag(:use, '', 'xlink:href' => "##{id}"),
      class: "icon #{id}"
    )
  end

  def values_for_attribute_dropdown(object, attr_info)
    picklist_values = object.class.
      distinct.order(attr_info.name).pluck(attr_info.name)
    picklist_values += attr_info.options.uniq if attr_info.options.present?
    picklist_values = picklist_values.flatten.uniq
    picklist_values.compact
  end

  def picklist_class(is_multiple)
    "js-form-input #{if is_multiple
                       'js-multiple-select'
                     else
                       'js-multisingle-select'
                     end}"
  end

  def nav_links
    return [] if @model.blank?
    [
      {
        name: 'Overview',
        path: model_url(@model),
        key: 'models'
      }, {
        name: 'Indicators',
        path: model_indicators_url(@model),
        key: 'indicators'
      }, {
        name: 'Scenarios',
        path: model_scenarios_url(@model),
        key: 'scenarios'
      }
    ]
  end
end
