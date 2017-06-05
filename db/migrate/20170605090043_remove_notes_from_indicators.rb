class RemoveNotesFromIndicators < ActiveRecord::Migration[5.0]
  def change
    remove_column :indicators, :notes
  end
end
