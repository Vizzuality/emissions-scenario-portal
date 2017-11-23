class IndicatorsHeaders
  include CsvUploadHeaders

  EXPECTED_HEADERS = [
    {
      display_name: 'ESP Indicator Name',
      property_name: :slug
    },
    {
      display_name: 'Model Indicator Name',
      property_name: :model_slug
    },
    {
      display_name: 'Stackable sub-category?',
      property_name: :stackable_subcategory
    },
    {
      display_name: 'Standardized Unit',
      property_name: :unit
    },
    {
      display_name: 'Unit of Entry',
      property_name: :unit_of_entry
    },
    {
      display_name: 'Conversion factor',
      property_name: :conversion_factor
    },
    {
      display_name: 'Definition',
      property_name: :definition
    }
  ].freeze

  EXPECTED_PROPERTIES = Hash[
    EXPECTED_HEADERS.map.with_index do |header, index|
      [header[:property_name], header.merge(index: index)]
    end
  ].freeze

  def initialize(path, model, encoding)
    @encoding = encoding
    initialize_headers(path)
    @model = model
    @fus = FileUploadStatus.new(:headers, @headers.length, 0)
    upload_template_path =
      if @model
        url_helpers.upload_template_model_indicators_path(@model)
      else
        url_helpers.upload_template_indicators_path
      end
    parse_headers(upload_template_path)
  end

  def parse_headers(template_url)
    expected_headers = EXPECTED_HEADERS.map { |eh| eh[:display_name] }
    if @model
      expected_headers = expected_headers.map do |eh|
        eh.sub(/Model/, @model.abbreviation)
      end
    end
    expected_headers = expected_headers.map do |eh|
      eh.downcase.gsub(/[^a-z0-9]/i, '')
    end
    @actual_headers = @headers.
      map { |ah| ah.downcase.gsub(/[^a-z0-9]/i, '') }.
      map do |header|
      expected_index =
        if header == 'modelabbreviationindicatorname'
          # this is in case somebody has not amended the model name header
          expected_headers.index("#{@model.abbreviation.downcase}indicatorname")
        else
          expected_headers.index(header)
        end
      if expected_index.present?
        {
          display_name: header,
          expected_index: expected_index
        }
      else
        unrecognised_header_error(template_url, header, nil)
        {
          display_name: header
        }
      end
    end
  end
end
