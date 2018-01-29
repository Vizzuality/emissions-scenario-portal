class AddUniqueIndexToTimeSeriesValues < ActiveRecord::Migration[5.1]
  TimeSeriesValue = Class.new(ApplicationRecord)

  def change
    TimeSeriesValue.
      select(%i[scenario_id indicator_id location_id year]).
      group(%i[scenario_id indicator_id location_id year]).
      having('count(*) > 1').
      each do |time_series_value|
      conditions = time_series_value.attributes.except('id')
      latest_id = TimeSeriesValue.where(conditions).order(:id).last.id
      TimeSeriesValue.where(conditions).where.not(id: latest_id).destroy_all
    end

    add_index(
      :time_series_values,
      %i[scenario_id indicator_id location_id year],
      name: :unique_index_time_series_values,
      unique: true
    )
  end
end
