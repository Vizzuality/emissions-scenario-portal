require 'csv'

class CsvVerticalUploadTemplate
  def headers
    [
      'Category', 'Indicator', 'Definition/Input Explanation', 'Data Type',
      'Picklist options (Data Entry)'
    ]
  end

  def export
    CSV.generate do |csv|
      csv << headers
      property_names.each do |property_name|
        attr_info = data_class.attribute_info(property_name)
        csv << [
          attr_info.category,
          I18n.t(data_class.key_for_name(property_name)),
          I18n.t(data_class.key_for_definition(property_name)),
          attr_info.input_type_for_display,
          attr_info.options.try(:join, '; '),
          nil
        ]
      end
    end
  end
end
