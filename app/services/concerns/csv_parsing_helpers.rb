module CsvParsingHelpers
  private

  def csv
    return @csv if defined?(@csv)
    file = Paperclip.io_adapters.for(csv_upload.data)
    encoding = CharlockHolmes::EncodingDetector.detect(file.read)[:encoding]
    @csv = CSV.open(file.path, 'r', headers: true, encoding: encoding).read
  end

  def parse_headers(headers)
    csv.headers.map do |header|
      headers.
        transform_values(&:downcase).
        key(header.to_s.downcase.gsub(/\s+/, ' ').strip) || header
    end
  end

  def valid_headers?(headers)
    (headers.keys - parse_headers(headers)).each do |value|
      errors.add(:base, :missing_header, msg: "Missing header #{value}", row: 1)
    end
  end

  def add_error(type, message, attrs = {})
    errors.add(:base, type, msg: message, **attrs)
    false
  end

  def models
    @models ||= Hash.new do |hash, model_abbreviation|
      hash[model_abbreviation] =
        Pundit.
          policy_scope(csv_upload.user, Model).
          find_by_abbreviation(model_abbreviation)
    end
  end

  def scenarios
    @scenarios ||= Hash.new do |hash, (model, scenario_name)|
      hash[[model, scenario_name]] =
        model&.scenarios&.find_by_name(scenario_name)
    end
  end

  def indicators
    @indicators ||= Hash.new do |hash, indicator_name|
      hash[indicator_name] =
        Indicator.find_by_name(indicator_name)
    end
  end

  def locations
    @locations ||= Hash.new do |hash, location_name|
      hash[location_name] =
        Location.find_by_name_or_iso_code(location_name)
    end
  end

  def notes
    @notes ||= Hash.new do |hash, (model, indicator)|
      hash[[model, indicator]] =
        Note.find_by(model: model, indicator: indicator)
    end
  end

  def categories
    @categories ||= Hash.new do |hash, category_name|
      hash[category_name] =
        Category.find_by_name(category_name)
    end
  end

  def subcategories
    @subcategories ||= Hash.new do |hash, (category, subcategory_name)|
      hash[[category, subcategory_name]] =
        category&.
          subcategories&.
          find_by_name(subcategory_name)
    end
  end

  def skip_incomplete(row, column)
    row[column].kind_of?(ApplicationRecord) || add_error(
      :"#{column}_not_found",
      "#{column.to_s.titleize} does not exist #{row[column]}",
      row.slice(:row)
    )
  end

  def skip_duplicate(set, row, scope)
    set.add?(row.values_at(*scope)) || add_error(
      :duplicate_row,
      "Unable to import rows overwriting already imported records",
      row.slice(:row)
    )
  end
end
