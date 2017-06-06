namespace :clear do
  desc 'Clears all time series values'
  task time_series_values: :environment do
    TimeSeriesValue.delete_all
  end

  desc 'Clears all indicators (and linked time series values)'
  task indicators: :time_series_values do
    Indicator.delete_all
  end

  desc 'Clears all scenarios (and linked time series values)'
  task scenarios: :time_series_values do
    Scenario.delete_all
  end

  desc 'Clears all locations (and linked time series values)'
  task locations: :time_series_values do
    Location.delete_all
  end

  desc 'Clears all models (scenarios, indicators and time series values)'
  task models: [:scenarios, :indicators] do
    Model.delete_all
  end
end
