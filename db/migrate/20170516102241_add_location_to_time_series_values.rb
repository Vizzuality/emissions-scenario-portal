class AddLocationToTimeSeriesValues < ActiveRecord::Migration[5.0]
  def change
    add_reference :time_series_values, :location, index: true, foreign_key: true
  end
end
