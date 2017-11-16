class ModelsUploadTemplate < CsvVerticalUploadTemplate
  def headers
    super + ['Model 1']
  end

  def property_names
    ModelsData::PROPERTY_NAMES
  end

  def data_class
    ModelsData::DATA_CLASS
  end
end
