class RenameAliasToCompositeNameInIndicators < ActiveRecord::Migration[5.1]
  def change
    rename_column :indicators, :alias, :composite_name
  end
end
