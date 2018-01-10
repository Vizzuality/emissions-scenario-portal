class AddTimeSeriesValuesCountToScenarios < ActiveRecord::Migration[5.1]
  class Scenario < ApplicationRecord
    has_many :time_series_values
  end
  class TimeSeriesValue < ApplicationRecord
    belongs_to :scenario, counter_cache: true
  end

  def change
    add_column :scenarios, :time_series_values_count, :integer, default: 0

    reversible do |dir|
      dir.up do
        Scenario.
          pluck(:id).
          each { |id| Scenario.reset_counters(id, :time_series_values) }
      end
    end
  end
end
