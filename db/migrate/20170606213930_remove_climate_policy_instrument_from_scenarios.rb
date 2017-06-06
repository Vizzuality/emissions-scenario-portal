class RemoveClimatePolicyInstrumentFromScenarios < ActiveRecord::Migration[5.0]
  def change
    remove_column :scenarios, :climate_policy_instrument
  end
end
