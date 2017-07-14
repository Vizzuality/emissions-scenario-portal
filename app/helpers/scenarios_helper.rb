module ScenariosHelper
  def values_for_scenario_model_dropdown(scenario)
    selection = scenario.model
    select_values = Model.select(:id, :abbreviation).map do |m|
      [m.abbreviation, m.id]
    end
    [select_values, selection]
  end

  def destroy_confirmation_message(scenario)
    time_series_data = 'Time series data exists for this indicator. '
    message = 'Are you sure you want to proceed?'
    message.prepend time_series_data if scenario.time_series_data?
    message
  end
end
