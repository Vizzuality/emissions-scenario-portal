class ChangeDiscountRatesFromArrayToTextInScenarios < ActiveRecord::Migration[5.0]
  def change
    change_column :scenarios, :discount_rates, :text
  end
end
