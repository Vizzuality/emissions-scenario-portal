class RemoveCategoryAndClassificationFromModels < ActiveRecord::Migration[5.0]
  def change
    remove_column :models, :category
    remove_column :models, :category_detailed
    remove_column :models, :hybrid_classification
    remove_column :models, :hybrid_classification_detailed
  end
end
