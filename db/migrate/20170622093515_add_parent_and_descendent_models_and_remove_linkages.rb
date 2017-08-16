class AddParentAndDescendentModelsAndRemoveLinkages < ActiveRecord::Migration[5.0]
  def change
    add_column :models, :parent_model, :text
    add_column :models, :descendent_models, :text
    remove_column :models, :linkages_and_extensions
  end
end
