class ModifyColumnsInModels < ActiveRecord::Migration[5.1]
  def change
    rename_column :models, :platform_detailed, :platform
    add_column :models, :technology_choice, :text
    add_column :models, :global_warming_potentials, :text
    add_column :models, :technology_constraints, :text
    add_column :models, :trade_restrictions, :text
    add_column :models, :solar_power_supply, :text
    add_column :models, :wind_power_supply, :text
    add_column :models, :bioenergy_supply, :text
    add_column :models, :co2_storage_supply, :text
  end
end
