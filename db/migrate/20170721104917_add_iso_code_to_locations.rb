class AddIsoCodeToLocations < ActiveRecord::Migration[5.0]
  def change
    add_column :locations, :iso_code, :string
  end
end
