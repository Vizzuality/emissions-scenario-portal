class MoveVariationsToNotes < ActiveRecord::Migration[5.1]
  class Model < ApplicationRecord; end
  class Indicator < ApplicationRecord
    belongs_to :model
  end
  class Note < ApplicationRecord; end

  def change
    migrate_data
  end

  private

  def migrate_data
    reversible do |dir|
      say_with_time 'migrate_data' do
        dir.up { migrate_data_up }
        dir.down { migrate_data_down }
      end
    end
  end

  def migrate_data_up
    Indicator.where.not(parent_id: nil).find_each do |indicator|
      note = Note.find_or_create_by!(
        indicator_id: indicator.parent_id,
        model_id: indicator.model.id
      )

      note.update!(
        description: indicator.definition,
        unit_of_entry: indicator.unit_of_entry,
        conversion_factor: indicator.conversion_factor
      )
    end
  end

  def migrate_data_down
    Indicator.where.not(parent_id: nil).find_each do |indicator|
      Note.find_by(
        indicator_id: indicator.parent_id,
        model_id: indicator.model_id
      ).try(:destroy)
    end
  end
end
