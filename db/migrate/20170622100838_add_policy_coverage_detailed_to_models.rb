class AddPolicyCoverageDetailedToModels < ActiveRecord::Migration[5.0]
  def change
    add_column :models, :policy_coverage_detailed, :text
  end
end
