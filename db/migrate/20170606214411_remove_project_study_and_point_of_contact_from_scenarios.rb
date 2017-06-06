class RemoveProjectStudyAndPointOfContactFromScenarios < ActiveRecord::Migration[5.0]
  def change
    remove_column :scenarios, :project_study
    remove_column :scenarios, :point_of_contact
  end
end
