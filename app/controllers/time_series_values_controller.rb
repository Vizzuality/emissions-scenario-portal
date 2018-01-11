class TimeSeriesValuesController < ApplicationController
  def index
    model = Model.find_by(id: params[:model_id])
    parent =
      Scenario.find_by(id: params[:scenario_id]) ||
      Indicator.find_by(id: params[:indicator_id])

    raise ActiveRecord::RecordNotFound if parent.blank?

    time_series_values = parent.time_series_values

    if model.present?
      time_series_values =
        time_series_values.
          joins(:scenario).
          where(scenarios: {model_id: model})
    end

    csv_download =
      DownloadTimeSeriesValues.
        new(current_user).
        call(time_series_values)

    send_data(
      csv_download.export,
      type: 'text/csv; charset=utf-8; header=present',
      disposition: "attachment; filename=#{parent.class.name.downcase}_time_series_data.csv"
    )
  end
end
