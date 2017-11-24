class MoveIndicatorsToNotes < ActiveRecord::Migration[5.1]
  class MissingConversionFactor < StandardError; end

  class Indicator < ApplicationRecord; end
  class Note < ApplicationRecord; end

  CONVERSION_FACTORS = {
    "EJ/yr-TWh/yr" => 0.0036,
    "TWh/yr-EJ/yr" => 277.8,
    "billion US$2016/yr-billion US$2012/yr" => 1.0454,
    "billion US$2016/yr-billion US$2010/yr" => 1.1007,
    "Mt CO2e/yr-Mmt CO2/yr" => 1.10231131
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
            CONVERSION_FACTORS["#{parent.unit}-#{attributes[:unit_of_entry]}"]

          puts "indicator.id: #{indicator.id}, parent.unit: #{parent.unit}, indicator.unit_of_entry: #{indicator.unit_of_entry}" if attributes[:conversion_factor].blank?
        end
      end

      note.update(attributes) if attributes.present?
    end
  end
end
