class AddUniqueIndexOnAliasToIndicators < ActiveRecord::Migration[5.1]
  class Indicator < ApplicationRecord; end

  def change
    # rename duplicates
    Indicator.
      select(:alias).
      group(:alias).
      having('count(*) > 1').
      each do |dup|
      Indicator.where(alias: dup.alias).find_each.with_index do |indicator, i|
        indicator.update!(alias: "#{indicator.alias}-#{i+1}") if i > 0
      end
    end

    add_index :indicators, :alias, unique: true
  end
end
