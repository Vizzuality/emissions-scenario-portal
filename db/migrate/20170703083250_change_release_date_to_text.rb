class ChangeReleaseDateToText < ActiveRecord::Migration[5.0]
  def change
    change_column :scenarios, :release_date, :text
  end
end
