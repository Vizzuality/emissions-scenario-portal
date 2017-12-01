class TimeSeriesValuesController < ApplicationController
  def index
    parent =
      Scenario.find_by(id: params[:scenario_id]) ||
      Indicator.find_by(id: params[:indicator_id])

    raise ActiveRecord::RecordNotFound if parent.blank?

    csv_download =
      DownloadTimeSeriesValues.
        new(current_user).
        call(parent.time_series_values)

    send_data(
      csv_download.export,
      type: 'text/csv; charset=utf-8; header=present',
      disposition: "attachment; filename=#{parent.class.name.downcase}_time_series_data.csv"
    )
  end
end
