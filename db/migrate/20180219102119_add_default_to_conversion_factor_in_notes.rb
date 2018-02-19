class AddDefaultToConversionFactorInNotes < ActiveRecord::Migration[5.1]
  def change
    change_column :notes, :conversion_factor, :decimal, default: 1
  end
end
