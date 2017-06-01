class IndicatorsData
  attr_reader :number_of_rows, :number_of_rows_failed, :errors

  def initialize(path, user, model)
    @path = path
    @user = user
    @model = model
    @headers = IndicatorsHeaders.new(@path, @model)
    @number_of_rows = File.foreach(@path).count - 1
    @number_of_rows_failed, @errors =
      if @headers.errors.any?
        [@number_of_rows, @headers.errors]
      else
        [0, {}]
      end
  end

  def process
    return if @errors.any?
    CSV.open(@path, 'r', headers: true).each.with_index(2) do |row, row_no|
      process_row(row, row_no)
    end
  end

  def process_row(row, row_no)
    @errors[row_no] = {}

    attributes = {
      stackable_subcategory: value_for(row, :stackable_subcategory),
      unit: value_for(row, :unit),
      unit_of_entry: value_for(row, :unit_of_entry),
      conversion_factor: value_for(row, :conversion_factor),
      definition: value_for(row, :definition)
    }

    slug = value_for(row, :slug)
    slug_hash = Indicator.slug_to_hash(slug)
    indicator = Indicator.where(slug_hash).first

    if indicator.nil?
      indicator = Indicator.new(slug_hash.merge(attributes))
      unless indicator.save
        @errors[row_no] = indicator.errors
        indicator = nil
      end
    else
      unless indicator.update_attributes(attributes)
        @errors[row_no] = indicator.errors
        indicator = nil
      end
    end

    if indicator.present?
      model_slug = value_for(row, :model_slug)
      model_indicator = Indicator.where(
        alias: model_slug, model: @model.id, parent_id: indicator
      ).first
      if model_indicator.nil?
        model_indicator = Indicator.new(
          slug_hash.merge(attributes).merge(
            alias: model_slug, model_id: @model.id, parent_id: indicator.id
          )
        )
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

  def value_for(row, property_name)
    row[@headers.actual_index_for_property(property_name)]
  end
end
