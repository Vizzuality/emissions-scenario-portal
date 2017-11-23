class MoveVariationsToNotes < ActiveRecord::Migration[5.1]
  CONVERSION_FACTORS = {
    "EJ/yr-TWh/yr" => 0.0036,
    "TWh/yr-EJ/yr" => 277.8,
    "billion US$2016/yr-billion US$2012/yr" => 1.0454
  }

  class Model < ApplicationRecord; end
  class Indicator < ApplicationRecord
    belongs_to :model
    belongs_to :parent, class_name: "MoveVariationsToNotes::Indicator"
  end
  # class Note < ApplicationRecord; end

  def change
    break_circular_associations
    create_notes
    promote_team_indicators_to_system_indicators
    assign_time_series_values_to_system_indicators
    delete_non_system_indicators
  end

  private

  def create_notes
    Indicator.where.not(model_id: nil).find_each do |indicator|
      parent = indicator.parent || indicator

      note = Note.find_or_initialize_by(
        indicator_id: parent.id,
        model_id: indicator.model_id
      )

      attributes = {}

      if indicator.definition.present?
        attributes[:description] = indicator.definition
      end

      if indicator.unit_of_entry.present? && indicator.unit_of_entry != parent.unit
        attributes[:unit_of_entry] = indicator.unit_of_entry
        attributes[:conversion_factor] = indicator.conversion_factor

        if indicator.conversion_factor == 0 || indicator.conversion_factor.nil?
          attributes[:conversion_factor] =
            CONVERSION_FACTORS[[parent.unit, indicator.unit_of_entry].join('-')]
        end
      end

      note.update!(attributes) if attributes.present?
    end
  end

  def break_circular_associations
    Indicator.where('parent_id = id').find_each do |indicator|
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
        indicator.update!(parent: parent)
      end
    end
  end

  def promote_team_indicators_to_system_indicators
    Indicator.
      where.not(model_id: nil).
      where(parent_id: nil).
      update_all(model_id: nil)
  end

  def assign_time_series_values_to_system_indicators
    Indicator.where.not(parent_id: nil).find_each do |indicator|
      TimeSeriesValue.
        where(indicator_id: indicator.id).
        update_all(indicator_id: indicator.parent_id)
    end
  end

  def delete_non_system_indicators
    Indicator.where.not(parent_id: nil).delete_all
  end
end
