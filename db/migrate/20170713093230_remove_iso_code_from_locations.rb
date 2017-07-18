class RemoveIsoCodeFromLocations < ActiveRecord::Migration[5.0]
  def change
    remove_column :locations, :iso_code2
  end
end
