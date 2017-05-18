module ScenariosHelper
  def destroy_confirmation_message(scenario)
    time_series_data = 'Time series data exists for this indicator. '
    message = 'Are you sure you want to proceed?'
    message.prepend time_series_data if scenario.time_series_data?
    message
  end
end
