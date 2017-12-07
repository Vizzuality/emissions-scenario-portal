class AssignTimeSeriesValuesToSystemIndicators < ActiveRecord::Migration[5.1]
  class TimeSeriesValue < ApplicationRecord; end
  class Indicator < ApplicationRecord; end
  class IncompatibleUnits < StandardError; end

  def change
    Indicator.where.not(parent_id: nil).find_each do |indicator|
      # find an actual parent in theoretically one level deep structure
      parent = indicator
      parent = Indicator.find(parent.parent_id) while parent.parent_id.present?

      if indicator.unit != parent.unit
        conversion_factor = AddMissingConversionFactors::CONVERSION_FACTORS[
          [indicator.unit, parent.unit].join('->')
        ]
        if conversion_factor
          TimeSeriesValue.
            where(unit_of_entry: indicator.unit, indicator_id: indicator.id).
            update_all(['value = value * ?, unit_of_entry = ?', conversion_factor, parent.unit])
        else
          unit = MoveIndicatorsToNotes::UNIT_RESOLUTIONS[
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
