class RemoveNotNullConstraintFromIndicatorName < ActiveRecord::Migration[5.0]
  def change
    change_column :indicators, :name, :text, null: true
    Indicator.where('category IS NULL').update_all(category: 'TODO')
    change_column :indicators, :category, :text, null: false
  end
end
