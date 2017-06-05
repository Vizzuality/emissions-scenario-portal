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
    unless slug || model_slug
      @errors[row_no] = {
        error: 'At least one of ESP Slug and Model Indicator name required'
      }
      return
    end

    id_attributes = Indicator.slug_to_hash(slug)
    attributes = {
      stackable_subcategory: value_for(row, :stackable_subcategory),
      unit: value_for(row, :unit),
      unit_of_entry: value_for(row, :unit_of_entry),
      conversion_factor: value_for(row, :conversion_factor),
      definition: value_for(row, :definition)
    }
    if id_attributes.any?
      indicator = Indicator.where(id_attributes).first
      if indicator.nil?
        indicator = Indicator.new(id_attributes.merge(attributes))
        unless indicator.save
          @errors[row_no] = indicator.errors
          indicator = nil
        end
      else
        if model_slug.present?
          attributes = attributes.except(
            :unit_of_entry, :conversion_factor, :definition
          )
        end
        unless indicator.update_attributes(attributes)
          @errors[row_no] = indicator.errors
          indicator = nil
        end
      end
    end
    if @errors[row_no].empty?
      model_indicator = Indicator.where(
        alias: model_slug, model: @model.id
      )
      if indicator.present?
        model_indicator = model_indicator.where(
          parent_id: indicator.id
        )
      else
        unless id_attributes.any?
          id_attributes = Indicator.slug_to_hash(
            model_slug
          )
        end
        model_indicator = model_indicator.where(id_attributes)
      end
      model_indicator = model_indicator.first

      if model_indicator.nil?
        model_indicator = Indicator.new(
          id_attributes.merge(attributes).merge(
            alias: model_slug, model_id: @model.id
          )
        )
        model_indicator.parent = indicator if indicator.present?
        @errors[row_no] = model_indicator.errors unless model_indicator.save
      else
        unless model_indicator.update_attributes(attributes)
          @errors[row_no] = model_indicator.errors
        end
      end
    end

    if @errors[row_no].any?
      @number_of_rows_failed += 1
    else
      @errors.delete(row_no)
    end
  end
end
