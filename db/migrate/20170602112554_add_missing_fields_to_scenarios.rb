class AddMissingFieldsToScenarios < ActiveRecord::Migration[5.0]
  def change
    add_column :scenarios, :proposed_portal_name, :text
    add_column :scenarios, :climate_policy_instrument, :text
  end
end
