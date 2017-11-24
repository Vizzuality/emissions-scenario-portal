class NormalizeUnitNames < ActiveRecord::Migration[5.1]
  UNITS = {
    "billion kWh/year" => "TWh/yr",
    "Billion kWh/year" => "TWh/yr",
    "EJ/year" => "EJ/yr",
    "billion 2010 $US/yr" => "billion US$2010/yr",
    "billion 2016 $US/yr" => "billion US$2016/yr",
    "billion 2010 $US/year" => "billion US$2010/yr",
    "billion 2016 $US/year" => "billion US$2016/yr",
    "Mt CO2-equiv/yr" => "Mt CO2e/yr",
    "million metric tons/yr" => "Mmt/yr",
    "Mmt CO2/year" => "Mmt CO2/yr",
    "Mmt CO2/year" => "Mmt CO2/yr",
    "Mmt/yr" => "Mmt/yr",
    "million metric tons CO2e/yr" => "Mmt CO2e/yr"
  }

  def change
    UNITS.each do |unit, normalized_unit|
      Indicator.where(unit: unit).update_all(unit: normalized_unit)
      Indicator.where(unit_of_entry: unit).update_all(unit_of_entry: normalized_unit)
      TimeSeriesValue.where(unit_of_entry: unit).update_all(unit_of_entry: normalized_unit)
    end
  end
end
