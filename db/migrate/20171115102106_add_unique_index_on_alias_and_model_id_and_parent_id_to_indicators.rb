class AddUniqueIndexOnAliasAndModelIdAndParentIdToIndicators < ActiveRecord::Migration[5.1]
  class Indicator < ActiveRecord::Base; end

  def change
    add_index :indicators, [:model_id, :parent_id, :alias], unique: true
  end
end
