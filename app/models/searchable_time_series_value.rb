class SearchableTimeSeriesValue < ApplicationRecord
  self.table_name = 'searchable_time_series_values'

  def readonly?
    true
  end

  def self.refresh
    Scenic.database.refresh_materialized_view(table_name, concurrently: false)
  end
end
