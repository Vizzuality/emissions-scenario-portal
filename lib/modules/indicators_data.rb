require 'indicators_headers'

class IndicatorsData
  include CsvUploadData
  attr_reader :number_of_rows, :number_of_rows_failed, :errors

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
      @errors[row_no] = {
        error: 'At least one of ESP Slug and Model Indicator name required'
      }
    end
    if @errors[row_no].any?
      @number_of_rows_failed += 1
    else
      @errors.delete(row_no)
    end
  end

  def process_core_indicator(slug, row, row_no)
    if @user.cannot?(:manage, Model)
      errors['model'] = 'Access denied: managing core indicators'
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
      errors['model'] = 'Access denied: managing model indicators'
      return nil
    end
    unless slug.present?
      return process_detached_indicator_variation(model_slug, row, row_no)
    end

    id_attributes = Indicator.slug_to_hash(slug)
    indicator = matching_object(
      Indicator.where(id_attributes),
      'indicator',
      "indicator: #{slug}",
      @errors[row_no]
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
      @errors[row_no] = indicator.errors unless indicator.save
    else
      unless indicator.update_attributes(attributes)
        @errors[row_no] = indicator.errors
      end
    end
  end
end
