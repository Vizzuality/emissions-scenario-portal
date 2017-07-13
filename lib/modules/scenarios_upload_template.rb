require 'csv_vertical_upload_template'
require 'scenarios_data'

class ScenariosUploadTemplate < CsvVerticalUploadTemplate
  def headers
    [
      'Category', 'Indicator', 'Definition/Input Explanation', 'Data Type',
      'Picklist options (Data Entry)', 'Scenario 1'
    ]
  end

  def property_names
    ScenariosData::PROPERTY_NAMES
  end

  def data_class
    ScenariosData::DATA_CLASS
  end
end
