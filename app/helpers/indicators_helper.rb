module IndicatorsHelper
  def categories_for_select
    options_for_select(
      Category.top_level.order(:name).pluck(:name, :id)
    )
  end

  def values_for_indicator_category_dropdown(indicator)
    select_values =
      Category.
        top_level.
        select(:id, :name).
        order(name: :asc).
        pluck(:name, :id)

    selection = indicator.category

    [select_values, selection, false]
  end

  def values_for_indicator_subcategory_dropdown(indicator)
    select_values =
      Category.
        second_level.
        select(:id, :name).
        order(name: :asc).
        pluck(:name, :id).
        map { |name, id| [name, id] }

    selection = indicator.subcategory

    [select_values, selection, false]
  end

  def destroy_confirmation_message(indicator)
    time_series_data = 'Time series data exists for this indicator. '
    message = 'Are you sure you want to proceed?'
    message.prepend time_series_data if indicator.time_series_data?
    message
  end

  def promote_confirmation_message(indicator)
    <<~EOM
      This will create a system indicator #{indicator.composite_name} and turn this indicator into its variation. Are you sure you want to proceed?
    EOM
  end
end
