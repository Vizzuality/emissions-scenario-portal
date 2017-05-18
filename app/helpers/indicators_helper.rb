module IndicatorsHelper
  def types_for_select
    options_for_select(
      [
        ['Added by your team', 'team'],
        ['Added by anyone', 'all']
      ]
    )
  end

  def categories_for_select
    options_for_select(
      @indicators.except(:order).order(:category).distinct.pluck(:category)
    )
  end

  def destroy_confirmation_message(indicator)
    time_series_data = 'Time series data exists for this indicator. '
    message = 'Are you sure you want to proceed?'
    message.prepend time_series_data if indicator.time_series_data?
    message
  end
end
