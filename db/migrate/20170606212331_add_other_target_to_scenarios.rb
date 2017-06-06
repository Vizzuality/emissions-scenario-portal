class AddOtherTargetToScenarios < ActiveRecord::Migration[5.0]
  def change
    add_column :scenarios, :other_target_type, :text
    add_column :scenarios, :other_target, :text
    remove_column :scenarios, :emissions_target
  end
end
