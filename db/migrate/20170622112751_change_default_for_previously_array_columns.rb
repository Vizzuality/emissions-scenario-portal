class ChangeDefaultForPreviouslyArrayColumns < ActiveRecord::Migration[5.0]
  def change
    change_column :models, :key_usage, :text, default: nil
    change_column :models, :scenario_coverage_detailed, :text, default: nil
    change_column :scenarios, :discount_rates, :text, default: nil
  end
end
