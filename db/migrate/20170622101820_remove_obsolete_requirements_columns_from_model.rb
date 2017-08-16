class RemoveObsoleteRequirementsColumnsFromModel < ActiveRecord::Migration[5.0]
  def change
    remove_column :models, :calibration_and_validation
    remove_column :models, :languages
    remove_column :models, :tutorial_and_training_opportunities
    remove_column :models, :system_requirements
    remove_column :models, :run_time
  end
end
