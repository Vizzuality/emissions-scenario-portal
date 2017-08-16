class AddConceptSolutionAndAnticipationToModels < ActiveRecord::Migration[5.0]
  def change
    add_column :models, :concept, :text
    add_column :models, :solution_method, :text
    add_column :models, :anticipation, :text, array: true, default: []
  end
end
