class RemoveUnnecessaryColumnsFromTimeSeriesValues < ActiveRecord::Migration[5.1]
  def change
    remove_column :time_series_values, :unit_of_entry, :text
    remove_column :time_series_values, :conversion_factor, :decimal
  end
end
