class AddModelToIndicators < ActiveRecord::Migration[5.0]
  def change
    add_reference :indicators, :model, index: true, foreign_key: true
  end
end
