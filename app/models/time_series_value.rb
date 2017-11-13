class TimeSeriesValue < ApplicationRecord
  include PgSearch

  belongs_to :scenario
  belongs_to :indicator
  belongs_to :location

  validates(
    :year,
    presence: true,
    numericality: {only_integer: true, allow_nil: true},
    inclusion: {in: 1900..3000, allow_nil: true}
  )
  validates :value, presence: true, numericality: {allow_nil: true}
  validate :unit_compatible_with_indicator, if: proc { |v| v.indicator }

  pg_search_scope :search_for, associated_against: {
                    scenario: :name,
                    location: :name
                  }

  def unit_compatible_with_indicator
    if unit_of_entry.present? &&
       unit_of_entry != indicator.unit &&
       unit_of_entry != indicator.unit_of_entry
      errors[:unit_of_entry] << 'Unit of entry incompatible with indicator.'
    end
  end

  def self.time_series_values_pivot
    pivot = TimeSeriesYearPivotQuery.new(self)
    query_sql = pivot.query_with_order(nil, nil)
    result = TimeSeriesValue.find_by_sql(query_sql)
    {
      years: pivot.years,
      data: result.map do |tsv|
        {
          scenario_name: tsv['scenario_name'],
          location_name: tsv['location_name'],
          unit_of_entry: tsv['unit_of_entry'],
          values: pivot.years.map { |y| tsv[y] }
        }
      end
    }
  end
end
