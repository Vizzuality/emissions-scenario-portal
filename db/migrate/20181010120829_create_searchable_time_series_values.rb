class CreateSearchableTimeSeriesValues < ActiveRecord::Migration[5.1]
  def change
    create_view :searchable_time_series_values, materialized: true
    add_index :searchable_time_series_values, :location_id
    add_index :searchable_time_series_values, :location
    add_index :searchable_time_series_values, :model_id
    add_index :searchable_time_series_values, :scenario_id
    add_index :searchable_time_series_values, :indicator_id
    add_index :searchable_time_series_values, :category_id
    add_index :searchable_time_series_values, :subcategory_id
  end
end
