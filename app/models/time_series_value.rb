class TimeSeriesValue < ApplicationRecord
  include PgSearch

  ORDERS = %w[scenario location unit_of_entry].freeze

  belongs_to :scenario
  belongs_to :indicator
  belongs_to :location

  validates(
    :year,
    presence: true,
    numericality: {only_integer: true, allow_nil: true},
    inclusion: {in: 1900..2100, allow_nil: true}
  )
  validates :value, presence: true, numericality: {allow_nil: true}
  validates :scenario, presence: true
  validates :indicator, presence: true
  validates :location, presence: true
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

  class << self
    def fetch_all(time_series_values, options)
      time_series_values = apply_search_filter(
        time_series_values, options
      )
      pivot = TimeSeriesYearPivotQuery.new(time_series_values)
      query_sql = pivot.query_with_order(
        options.delete('order_type'),
        options.delete('order_direction')
      )
      result = TimeSeriesValue.find_by_sql(query_sql)
      format_pivot_result(pivot, result)
    end

    def apply_search_filter(relation, options)
      search_term = options.delete('search')
      return relation unless search_term.present?
      relation.search_for(search_term).except(:order)
    end

    def format_pivot_result(pivot, result)
      years = pivot.years
      data = result.map do |tsv|
        {
          scenario_name: tsv['scenario_name'],
          location_name: tsv['location_name'],
          unit_of_entry: tsv['unit_of_entry'],
          values: years.map { |y| tsv[y] }
        }
      end
      {
        years: years,
        data: data
      }
    end
  end
end
