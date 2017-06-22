class AddBehaviourAndLandUseToModels < ActiveRecord::Migration[5.0]
  def change
    add_column :models, :behaviour, :text
    add_column :models, :land_use, :text
  end
end
