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
                column: 'id',
                alias: 'id',
                visible: false
              },
              {
                column: 'iso_code2',
                alias: 'iso_code2'
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
                column: 'composite_name',
                alias: 'composite_name'
              },
              {
                column: 'unit',
                alias: 'unit'
              },
              {
                column: 'definition',
                alias: 'definition'
              },
              {
                column: 'unit',
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
