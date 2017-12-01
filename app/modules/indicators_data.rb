class IndicatorsData
  include CsvUploadData

  def initialize(path, user, encoding)
    @path = path
    @user = user
    @encoding = encoding
    @headers = IndicatorsHeaders.new(@path, @encoding)
    initialize_stats
  end

  def process_row(row, row_no)
    @fus.init_errors_for_row_or_col(row_no)
    slug = value_for(row, :slug)

    if slug.present?
      process_indicator(slug, row, row_no)
    else
      message = 'ESP Indicator Name must be present.'
      suggestion = 'Please fill in missing data.'
      @fus.add_error(row_no, 'slug', format_error(message, suggestion))
    end

    if @fus.errors_for_row_or_col?(row_no)
      @fus.increment_number_of_records_failed
    else
      @fus.clear_errors(row_no)
    end
  end

  def process_indicator(slug, row, row_no)
    unless Pundit.policy(@user, Indicator).create?
      message = 'Access denied to manage indicators.'
      suggestion = 'ESP admins curate indicators.'
      @fus.add_error(
        row_no, 'model', format_error(message, suggestion)
      )
      return nil
    end

    id_attributes = Indicator.slug_to_hash(slug)
    stackable_subcategory_raw = value_for(row, :stackable_subcategory)
    stackable_subcategory = stackable_subcategory_raw &&
      stackable_subcategory_raw.casecmp?('yes')

    common_attributes = {
      stackable_subcategory: stackable_subcategory,
      unit: value_for(row, :unit),
      definition: value_for(row, :definition)
    }

    id_attributes, common_attributes =
        indicator_attributes(id_attributes, common_attributes)
    indicator = Indicator.where(category: id_attributes[:category])
    [:subcategory, :name].each do |name_part|
      indicator =
        if id_attributes[name_part].blank?
          indicator.where("#{name_part} IS NULL OR #{name_part} = ?", '')
        else
          indicator.where(name_part => id_attributes[name_part])
        end
    end
    indicator = indicator.first
    attributes = id_attributes.merge(common_attributes)
    create_or_update_indicator(indicator, attributes, row_no)
  end

  def create_or_update_indicator(indicator, attributes, row_no)
    if indicator.nil?
      indicator = Indicator.new(attributes)
      return indicator if indicator.save
    elsif indicator.update_attributes(attributes)
      return indicator
    end
    process_other_errors(row_no, indicator.errors)
    nil
  end

  def indicator_attributes(id_attributes, common_attributes)
    category = Category.case_insensitive_find_or_create(
      name: id_attributes[:category]
    )

    subcategory = Category.case_insensitive_find_or_create(
      name: id_attributes[:subcategory],
      stackable: common_attributes[:stackable_subcategory],
      parent: category
    )

    [
      id_attributes.
        except(:category, :subcategory).
        merge(category: category, subcategory: subcategory),
      common_attributes.
        except(:stackable_subcategory)
    ]
  end
end
