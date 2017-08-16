class AddPurposeOrObjectiveToScenarios < ActiveRecord::Migration[5.0]
  def change
    add_column :scenarios, :purpose_or_objective, :text
  end
end
