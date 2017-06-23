class RemovePlatformFromModels < ActiveRecord::Migration[5.0]
  def change
    remove_column :models, :platform
  end
end
