class MakeScenarioNameNotNull < ActiveRecord::Migration[5.0]
  def change
    Scenario.where('name IS NULL').update_all(name: 'TODO')
    change_column :scenarios, :name, :text, null: false
  end
end
