class ScenariosUploadTemplate < CsvVerticalUploadTemplate
  def headers
    super + ['Scenario 1']
  end

  def property_names
    ScenariosData::PROPERTY_NAMES
  end

  def data_class
    ScenariosData::DATA_CLASS
  end
end
