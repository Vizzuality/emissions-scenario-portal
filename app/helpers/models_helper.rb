module ModelsHelper
  def attribute_name(attribute_symbol)
    t @model.key_for_name(attribute_symbol)
  end

  def attribute_definition(attribute_symbol)
    t @model.key_for_definition(attribute_symbol)
  end

  def attribute_input(attribute_symbol)
    if Model.is_picklist_attribute?(attribute_symbol)
      picklist_values = Model.
        distinct.order(attribute_symbol).pluck(attribute_symbol)
      if Model.is_multiple_attribute?(attribute_symbol)
        picklist_values = picklist_values.flatten.uniq
        'PICKLIST WITH MULTIPLE SELECTION'
      else
        'PICKLIST'
      end + ' (' + picklist_values.compact.join(', ') + ')'
    else
      'TEXT INPUT'
    end
  end
end
