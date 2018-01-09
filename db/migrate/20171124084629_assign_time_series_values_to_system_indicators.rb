class AssignTimeSeriesValuesToSystemIndicators < ActiveRecord::Migration[5.1]
  class TimeSeriesValue < ApplicationRecord; end
  class Indicator < ApplicationRecord; end
  class IncompatibleUnits < StandardError; end

  CONVERSION_FACTORS = {
    "TWh/yr->EJ/yr" => 0.0036,
    "Mt CH4/yr->Mt CO2e/yr" => 25,
    "kt N2O/yr->Mt CO2e/yr" => 0.001,
    "EJ/yr->TWh/yr" => 277.8,
    "billion US$2010/yr->billion US$2016/yr" => 1.1007,
    "billion US$2012/yr->billion US$2016/yr" => 1.0454
  }

  UNIT_RESOLUTIONS = {
    "GW->GW/yr" => "GW/yr",
    "GW->EJ/yr" => "EJ/yr"
  }

  def change
    Indicator.where.not(parent_id: nil).find_each do |indicator|
      # find an actual parent in theoretically one level deep structure
      parent = indicator
      parent = Indicator.find(parent.parent_id) while parent.parent_id.present?

      if indicator.unit != parent.unit
        conversion_factor = CONVERSION_FACTORS[
          [indicator.unit, parent.unit].join('->')
        ]
        if conversion_factor
          TimeSeriesValue.
            where(unit_of_entry: indicator.unit, indicator_id: indicator.id).
            update_all(['value = value * ?, unit_of_entry = ?', conversion_factor, parent.unit])
        else
          unit = UNIT_RESOLUTIONS[
            [indicator.unit, parent.unit].join('->')
          ]

          if unit
            indicator.update!(unit: unit)
            redo
          else
            puts "unable to convert indicator.id: #{indicator.id}, unit: #{indicator.unit}, parent #{parent.id}, parent.unit: #{parent.unit}"
            raise IncompatibleUnits
          end
        end
      end

      TimeSeriesValue.
        where(indicator_id: indicator.id).
        update_all(indicator_id: parent.id)
    end
  end
end
