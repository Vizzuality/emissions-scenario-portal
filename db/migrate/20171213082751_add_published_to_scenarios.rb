class AddPublishedToScenarios < ActiveRecord::Migration[5.1]
  def change
    add_column :scenarios, :published, :boolean, default: false, null: false
  end
end
