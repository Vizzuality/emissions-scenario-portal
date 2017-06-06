class AddAliasToIndicators < ActiveRecord::Migration[5.0]
  def change
    add_column :indicators, :alias, :text
  end
end
