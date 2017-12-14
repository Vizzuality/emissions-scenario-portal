class MakeCompositeNameIndexCaseInsensitiveInIndicators < ActiveRecord::Migration[5.1]
  class Indicator < ApplicationRecord; end
  class TimeSeriesValues < ApplicationRecord; end
  class Note < ApplicationRecord; end

  def change
    Indicator.
      group('LOWER(composite_name)').
      having('COUNT(*) > 1').
      count.each do |composite_name, _|

      indicators = Indicator.where('LOWER(composite_name) = ?', composite_name)

      indicator = indicators.first
      indicator_ids = indicators.pluck(:id)

      TimeSeriesValues.
        where(indicator_id: indicator_ids - [indicator.id]).
        update_all(indicator_id: indicator.id)
      Note.
        where(indicator_id: indicator_ids - [indicator.id]).
        update_all(indicator_id: indicator.id)
      Indicator.
        where(id: indicator_ids - [indicator.id]).
        destroy_all
    end

    remove_index :indicators, :composite_name
    add_index :indicators, 'LOWER(composite_name)', unique: true
  end
end
