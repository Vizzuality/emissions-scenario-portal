require 'indicators_headers'

class IndicatorsData
  include CsvUploadData
  attr_reader :number_of_records, :number_of_records_failed, :errors

  def initialize(path, user, model)
    @path = path
    @user = user
    @model = model
    @headers = IndicatorsHeaders.new(@path, @model)
    initialize_stats
  end

  def process_row(row, row_no)
    @errors[row_no] = {}
    slug = value_for(row, :slug)
    model_slug = value_for(row, :model_slug)
    if model_slug.present?
      process_indicator_variation(slug, model_slug, row, row_no)
    elsif slug.present?
      process_core_indicator(slug, row, row_no)
    else
      message = 'At least one of ESP Indicator Name and Model Indicator Name \
must be present.'
      suggestion = 'Please fill in missing data.'
      @errors[row_no]['slug'] = format_error(message, suggestion)
    end
    if @errors[row_no].any?
      @number_of_records_failed += 1
    else
      @errors.delete(row_no)
    end
  end

  def process_core_indicator(slug, row, row_no)
    if @user.cannot?(:manage, Model)
      message = 'Access denied to manage core indicators.'
      suggestion = 'ESP admins curate core indicators. Please add a model \
indicator instead.'
      errors['model'] = format_error(message, suggestion)
      return nil
    end
    id_attributes = Indicator.slug_to_hash(slug)
    attributes = {
      stackable_subcategory: value_for(row, :stackable_subcategory),
      unit: value_for(row, :unit),
      unit_of_entry: value_for(row, :unit_of_entry),
      conversion_factor: value_for(row, :conversion_factor),
      definition: value_for(row, :definition)
    }
    indicator = Indicator.where(id_attributes).first
    create_or_update_indicator(
      indicator, id_attributes.merge(attributes), row_no
    )
  end

  def process_indicator_variation(slug, model_slug, row, row_no)
    if @user.cannot?(:manage, @model)
      message = "Access denied to manage model indicators \
(#{model.abbreviation})."
      suggestion = 'Please verify your team\'s permissions [here].'
      errors['model'] = format_error(
        message,
        suggestion,
        url: url_helpers.model_url(@model),
        placeholder: 'here'
      )
      return nil
    end
    unless slug.present?
      return process_detached_indicator_variation(model_slug, row, row_no)
    end

    id_attributes = Indicator.slug_to_hash(slug)
    indicator = matching_object(
      Indicator.where(id_attributes).where('parent_id IS NULL'),
      'indicator',
      "indicator: #{slug}",
      @errors[row_no],
      url_helpers.model_indicators_path(@model)
    )
    return unless indicator

    attributes = id_attributes.merge(
      stackable_subcategory: value_for(row, :stackable_subcategory),
      unit: value_for(row, :unit),
      unit_of_entry: value_for(row, :unit_of_entry),
      conversion_factor: value_for(row, :conversion_factor),
      definition: value_for(row, :definition),
      alias: model_slug,
      model_id: @model.id,
      parent_id: indicator.id
    )

    model_indicator = Indicator.where(
      alias: model_slug, model: @model.id, parent_id: indicator.id
    ).first

    create_or_update_indicator(model_indicator, attributes, row_no)
  end

  def process_detached_indicator_variation(model_slug, row, row_no)
    model_indicator = Indicator.where(
      alias: model_slug, model_id: @model.id
    ).first
    id_attributes = Indicator.slug_to_hash(model_slug)
    attributes = id_attributes.merge(
      stackable_subcategory: value_for(row, :stackable_subcategory),
      unit: value_for(row, :unit),
      unit_of_entry: value_for(row, :unit_of_entry),
      conversion_factor: value_for(row, :conversion_factor),
      definition: value_for(row, :definition),
      alias: model_slug,
      model_id: @model.id
    )

    create_or_update_indicator(model_indicator, attributes, row_no)
  end

  def create_or_update_indicator(indicator, attributes, row_no)
    if indicator.nil?
      indicator = Indicator.new(attributes)
      return indicator if indicator.save
      process_other_errors(@errors[row_no], indicator.errors)
    else
      unless indicator.update_attributes(attributes)
        process_other_errors(
          @errors[row_no], indicator.errors
        )
      end
    end
  end
end
