require 'time_series_year_pivot_query'

class DownloadTimeSeriesValues
  def initialize(user)
    @user = user
  end

  def call(data)
    pivot = TimeSeriesYearPivotQuery.new(data)

    PgCsv.new(
      columns: pivot.all_column_headers,
      sql: pivot.query,
      type: :plain
    )
  end
end
