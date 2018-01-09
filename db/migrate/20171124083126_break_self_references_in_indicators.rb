class BreakSelfReferencesInIndicators < ActiveRecord::Migration[5.1]
  class TimeSeriesValue < ApplicationRecord; end
  class Indicator < ApplicationRecord; end

  def change
    Indicator.where('parent_id = id').find_each do |indicator|
      # try to find a parent indicator
      parent = Indicator.find_by!(alias: indicator.alias[0..-2])

      existing_indicator = Indicator.find_by(
        alias: indicator.alias,
        model_id: indicator.model_id,
        parent_id: parent.id
      )

      if existing_indicator.present?
        # there's another indicator with a given alias, model and parent
        # assign time series values to the existing one
        TimeSeriesValue.
          where(indicator_id: indicator.id).
          update_all(indicator_id: existing_indicator.id)
        indicator.delete
      else
        # assign the correct parent
        indicator.update(parent_id: parent.id)
      end
    end
  end
end
