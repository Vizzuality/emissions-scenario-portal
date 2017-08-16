class AddBurdenSharingToScenarios < ActiveRecord::Migration[5.0]
  def change
    add_column :scenarios, :burden_sharing, :text
  end
end
