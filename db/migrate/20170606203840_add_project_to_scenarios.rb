class AddProjectToScenarios < ActiveRecord::Migration[5.0]
  def change
    add_column :scenarios, :project, :text
  end
end
