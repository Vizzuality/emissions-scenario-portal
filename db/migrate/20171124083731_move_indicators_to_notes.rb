class MoveIndicatorsToNotes < ActiveRecord::Migration[5.1]
  class MissingConversionFactor < StandardError; end
  class IncompatibleUnits < StandardError; end

  class Indicator < ApplicationRecord; end
  class Note < ApplicationRecord; end

  UNIT_RESOLUTIONS = {
    "GW->GW/yr" => "GW/yr",
    "GW->EJ/yr" => "EJ/yr"
  }

  def change
    Indicator.where.not(model_id: nil).find_each do |indicator|
      # find an actual parent in theoretically one level deep structure
      parent = indicator
      parent = Indicator.find(parent.parent_id) while parent.parent_id.present?

      note = Note.find_or_initialize_by(
        indicator_id: parent.id,
        model_id: indicator.model_id
      )

      attributes = {}

      # indicator's definition becomes note's description
      if indicator.definition.present?
        attributes[:description] = indicator.definition
      end

      if indicator.unit_of_entry.present? && indicator.unit_of_entry != parent.unit
        if indicator.unit == parent.unit
          attributes[:unit_of_entry] = indicator.unit_of_entry
          attributes[:conversion_factor] = indicator.conversion_factor

          raise MissingConversionFactor if attributes[:conversion_factor].blank?
        else
          attributes[:unit_of_entry] = indicator.unit_of_entry
          attributes[:conversion_factor] =
            AddMissingConversionFactors::CONVERSION_FACTORS[
              [attributes[:unit_of_entry], parent.unit].join('->')
            ]

          if attributes[:conversion_factor].blank?
            unit = UNIT_RESOLUTIONS[[indicator.unit, parent.unit].join('->')]

            if unit
              indicator.update!(unit: unit)
              redo
            else
              puts "unable to create note for indicator.id: #{indicator.id}, parent.unit: #{parent.unit}, indicator.unit_of_entry: #{indicator.unit_of_entry}"
              raise IncompatibleUnits
            end
          end
        end
      end

      note.update(attributes) if attributes.present?
    end
  end
end
