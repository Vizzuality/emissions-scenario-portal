class AssignTimeSeriesValuesToSystemIndicators < ActiveRecord::Migration[5.1]
  class TimeSeriesValue < ApplicationRecord; end
  class Indicator < ApplicationRecord; end

  def change
    Indicator.where.not(parent_id: nil).find_each do |indicator|
      # find an actual parent in theoretically one level deep structure
      parent = indicator
      parent = Indicator.find(parent.parent_id) while parent.parent_id.present?

      TimeSeriesValue.
        where(indicator_id: indicator.id).
        update_all(indicator_id: parent.id)
    end
  end
end
