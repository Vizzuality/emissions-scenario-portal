class AddMissingConversionFactors < ActiveRecord::Migration[5.1]
  class MissingConversionFactor < StandardError; end
  class Indicator < ApplicationRecord; end

  CONVERSION_FACTORS = {
    "TWh/yr->EJ/yr" => 0.0036,
    "Mmt CO2/yr->Mt CO2e/yr" => 1.10231131,
    "Mt CH4/yr->Mt CO2e/yr" => 25,
    "kt N2O/yr->Mt CO2e/yr" => 0.001,
    "EJ/yr->TWh/yr" => 277.8,
    "billion US$2010/yr->billion US$2016/yr" => 1.1007,
    "billion US$2012/yr->billion US$2016/yr" => 1.0454
  }

  def change
    Indicator.
      where('unit != unit_of_entry').
      where(conversion_factor: [0, nil]).find_each do |indicator|

      conversion_factor = CONVERSION_FACTORS[
        [indicator.unit_of_entry, indicator.unit].join('->')
      ] || raise(MissingConversionFactor)

      indicator.update(conversion_factor: conversion_factor)
    end
  end
end
