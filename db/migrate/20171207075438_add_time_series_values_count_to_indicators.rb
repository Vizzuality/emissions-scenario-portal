class AddTimeSeriesValuesCountToIndicators < ActiveRecord::Migration[5.1]
  class Indicator < ApplicationRecord
    has_many :time_series_values
  end
  class TimeSeriesValue < ApplicationRecord
    belongs_to :indicator, counter_cache: true
  end

  def change
    add_column :indicators, :time_series_values_count, :integer, default: 0

    reversible do |dir|
      dir.up do
        Indicator.
          pluck(:id).
          each { |id| Indicator.reset_counters(id, :time_series_values) }
      end
    end
  end
end
