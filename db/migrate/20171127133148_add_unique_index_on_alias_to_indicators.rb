class AddUniqueIndexOnAliasToIndicators < ActiveRecord::Migration[5.1]
  def change
    add_index :indicators, :alias, unique: true
  end
end
