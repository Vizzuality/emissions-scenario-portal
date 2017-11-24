class NormalizeValuesInTimeSeriesValues < ActiveRecord::Migration[5.1]
  class TimeSeriesValue < ApplicationRecord; end

  def change
    connection.execute(
      <<-END_OF_SQL
        UPDATE time_series_values
        SET value = value * indicators.conversion_factor, unit_of_entry = indicators.unit
        FROM indicators
        WHERE time_series_values.unit_of_entry != indicators.unit AND time_series_values.indicator_id = indicators.id
      END_OF_SQL
    )
  end
end
