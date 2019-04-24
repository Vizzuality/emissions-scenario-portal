module Api
  module V1
    module Data
      module EmissionPathways
        module FilterColumns
          extend ActiveSupport::Concern

          private

          # rubocop:disable Metrics/MethodLength
          def select_columns_map
            [
              {
                column: 'time_series_values.id',
                alias: 'id',
                visible: false
              },
              {
                column: 'location',
                alias: 'location',
                display: 'Country / Region'
              },
              {
                column: 'model',
                alias: 'model'
              },
              {
                column: 'scenario',
                alias: 'scenario'
              },
              {
                column: 'category',
                alias: 'category'
              },
              {
                column: 'subcategory',
                alias: 'subcategory'
              },
              {
                column: 'indicator',
                alias: 'indicator'
              },
              {
                column: 'time_series_values.composite_name',
                alias: 'composite_name'
              },
              {
                column: 'time_series_values.definition',
                alias: 'definition'
              },
              {
                column: 'time_series_values.unit',
                alias: 'unit'
              },
              {
                column: emissions_select_column,
                alias: 'emissions',
                order: false,
                visible: false
              }
            ]
          end
          # rubocop:enable Metrics/MethodLength

          def emissions_select_column
            return 'emissions' unless @start_year || @end_year
            args_str = [
              'emissions',
              (@start_year || 'NULL').to_s + '::INT',
              (@end_year || 'NULL').to_s + '::INT'
            ].join(', ')
            "emissions_filter_by_year_range(#{args_str})::JSONB"
          end
        end
      end
    end
  end
end
