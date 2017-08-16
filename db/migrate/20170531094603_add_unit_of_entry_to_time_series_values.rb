class AddUnitOfEntryToTimeSeriesValues < ActiveRecord::Migration[5.0]
  def change
    add_column :time_series_values, :unit_of_entry, :text
    add_column :time_series_values, :conversion_factor, :numeric
  end
end
