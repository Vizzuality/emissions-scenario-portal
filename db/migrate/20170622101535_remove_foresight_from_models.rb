class RemoveForesightFromModels < ActiveRecord::Migration[5.0]
  def change
    remove_column :models, :foresight
  end
end
