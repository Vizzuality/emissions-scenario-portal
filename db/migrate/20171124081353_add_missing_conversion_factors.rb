class AddMissingConversionFactors < ActiveRecord::Migration[5.1]
  class MissingConversionFactor < StandardError; end

  class Indicator < ApplicationRecord; end

  CONVERSION_FACTORS = {
    "EJ/yr-TWh/yr" => 0.0036,
    "Mt CO2e/yr-Mmt CO2/yr" => 1.10231131,
    "Mt CO2e/yr-Mt CH4/yr" => 25,
    "Mt CO2e/yr-kt N2O/yr" => 0.001,
    "TWh/yr-EJ/yr" => 277.8,
    "billion US$2016/yr-billion US$2010/yr" => 1.1007,
    "billion US$2016/yr-billion US$2012/yr" => 1.0454
  }

  def change
    Indicator.
      where('unit != unit_of_entry').
      where(conversion_factor: [0, nil]).find_each do |indicator|

      conversion_factor = CONVERSION_FACTORS[
        [indicator.unit, indicator.unit_of_entry].join('-')
      ] || raise(MissingConversionFactor)

      indicator.update(conversion_factor: conversion_factor)
    end
  end
end
