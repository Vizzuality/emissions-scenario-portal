class RemoveProviderTypeFromScenarios < ActiveRecord::Migration[5.0]
  def change
    remove_column :scenarios, :provider_type
  end
end
