require 'csv_vertical_upload_template'
require 'models_data'

class ModelsUploadTemplate < CsvVerticalUploadTemplate
  def headers
    [
      'Category', 'Indicator', 'Definition/Input Explanation', 'Data Type',
      'Picklist options (Data Entry)', 'Model 1'
    ]
  end

  def property_names
    ModelsData::PROPERTY_NAMES
  end

  def data_class
    ModelsData::DATA_CLASS
  end
end
