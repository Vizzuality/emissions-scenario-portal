class RemoveLicenseDetailedAndMaintainerType < ActiveRecord::Migration[5.0]
  def change
    remove_column :models, :license_detailed
    remove_column :models, :maintainer_type
  end
end
