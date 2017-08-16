class RemoveProposedPortalNameFromScenarios < ActiveRecord::Migration[5.0]
  def change
    remove_column :scenarios, :proposed_portal_name
  end
end
