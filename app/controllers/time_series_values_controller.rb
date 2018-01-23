class TimeSeriesValuesController < ApplicationController
  def index
    model = Model.find_by(id: params[:model_id])
    parent =
      Scenario.find_by(id: params[:scenario_id]) ||
      Indicator.find_by(id: params[:indicator_id])

    raise ActiveRecord::RecordNotFound if parent.blank?

    time_series_values = parent.time_series_values

    if parent.is_a?(Indicator) && model.present?
      time_series_values = time_series_values.where(scenario_id: model.scenarios.select(:id))
    end

    results = TimeSeriesValuesPivotQuery.new(time_series_values).call

    csv_string = CSV.generate do |csv|
      csv << ["Model", "Scenario", "Region", "ESP Indicator Name"] + results.years
      results.each { |result| csv << result.values }
    end

    send_data(
      csv_string,
      type: 'text/csv; charset=utf-8; header=present',
      disposition: "attachment; filename=#{parent.class.name.downcase}_time_series_data.csv"
    )
  end
end
