class AddOvershootToScenarios < ActiveRecord::Migration[5.0]
  def change
    add_column :scenarios, :overshoot, :text
  end
end
