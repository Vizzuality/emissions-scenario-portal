class AddUniqueIndexesToLocations < ActiveRecord::Migration[5.1]
  class Location < ApplicationRecord
  end

  def change
    Location.where(iso_code: '').update(iso_code: nil)
    add_index :locations, :name, unique: true
    add_index :locations, :iso_code, unique: true
  end
end
