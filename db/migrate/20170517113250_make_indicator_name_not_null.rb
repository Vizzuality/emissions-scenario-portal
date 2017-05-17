class MakeIndicatorNameNotNull < ActiveRecord::Migration[5.0]
  def change
    Indicator.where('name IS NULL').update_all(name: 'TODO')
    change_column :indicators, :name, :text, null: false
  end
end
