class IndicatorsData
  include CsvUploadData

  def initialize(path, user, model, encoding)
    @path = path
    @user = user
    @model = model
    @encoding = encoding
    @headers = IndicatorsHeaders.new(@path, @model, @encoding)
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
    model_slug = value_for(row, :model_slug)
    id_attributes = Indicator.slug_to_hash(slug)
    stackable_subcategory_raw = value_for(row, :stackable_subcategory)
    stackable_subcategory = stackable_subcategory_raw &&
      stackable_subcategory_raw.casecmp?('yes')

    common_attributes = {
      stackable_subcategory: stackable_subcategory,
      unit: value_for(row, :unit),
      unit_of_entry: value_for(row, :unit_of_entry),
      conversion_factor: value_for(row, :conversion_factor),
      definition: value_for(row, :definition)
    }
    if !model_slug.present? || @user.admin?
      process_system_indicator(id_attributes, common_attributes, row_no)
    end
    return unless model_slug.present? && @model
    process_team_variation(
      id_attributes, common_attributes, model_slug, row_no
    )
  end

  def process_system_indicator(id_attributes, common_attributes, row_no)
    id_attributes, common_attributes =
        indicator_attributes(id_attributes, common_attributes)
    if @user.cannot?(:create, Indicator.new(model_id: nil))
      message = 'Access denied to manage core indicators.'
      suggestion = 'ESP admins curate core indicators. Please add a team \
indicator instead.'
      @fus.add_error(
        row_no, 'model', format_error(message, suggestion)
      )
      return nil
    end
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
    attributes = id_attributes.merge(common_attributes).merge(
      model_id: nil,
      parent_id: nil
    )
    create_or_update_indicator(
      indicator, attributes, row_no
    )
  end

  def process_team_variation(
    id_attributes, common_attributes, model_slug, row_no
  )
    id_attributes, common_attributes =
      indicator_attributes(id_attributes, common_attributes)

    if @user.cannot?(:create, Indicator.new(model_id: @model.id))
      message = "Access denied to manage team indicators \
(#{@model.abbreviation})."
      suggestion = 'Please verify your team\'s permissions [here].'
      link_options = {
        url: url_helpers.team_path(@user.team), placeholder: 'here'
      }
      @fus.add_error(
        row_no, 'model', format_error(message, suggestion, link_options)
      )
      return nil
    end
    slug = Indicator.hash_to_slug(id_attributes)
    indicator = Indicator.where(
      parent_id: nil, model_id: nil, alias: slug
    ).first
    if indicator.nil?
      team_indicator = Indicator.where(id_attributes).where(
        parent_id: nil, model_id: @model.id
      ).first
      attributes = id_attributes.merge(common_attributes).merge(
        alias: slug,
        model_id: @model.id,
        parent_id: nil
      )
      indicator = create_or_update_indicator(
        team_indicator, attributes, row_no
      )
    end
    return unless indicator

    team_variation = Indicator.where(
      parent_id: indicator.id, model_id: @model.id, alias: model_slug
    ).first
    attributes = id_attributes.merge(common_attributes).merge(
      alias: model_slug,
      model_id: @model.id,
      parent_id: indicator.id
    )

    create_or_update_indicator(team_variation, attributes, row_no)
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
