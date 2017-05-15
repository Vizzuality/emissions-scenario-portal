class CreateTimeSeriesValues < ActiveRecord::Migration[5.0]
  def change
    create_table :time_series_values do |t|
      t.references :scenario, foreign_key: true, index: true
      t.references :indicator, foreign_key: true, index: true
      t.integer :year
      t.numeric :value

      t.timestamps
    end
  end
end
