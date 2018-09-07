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
                column: 'indicators.id',
                alias: 'id',
                visible: false
              },
              {
                column: 'locations.iso_code',
                alias: 'iso_code2'
              },
              {
                column: 'locations.name',
                alias: 'location',
                display: 'Country / Region'
              },
              {
                column: 'models.full_name',
                alias: 'model'
              },
              {
                column: 'scenarios.name',
                alias: 'scenario'
              },
              {
                column: 'categories.name',
                alias: 'category'
              },
              {
                column: 'subcategories.name',
                alias: 'subcategory'
              },
              {
                column: 'indicators.name',
                alias: 'indicator'
              },
              {
                column: "REPLACE(indicators.composite_name, '|', ' | ')",
                alias: 'composite_name'
              },
              {
                column: 'indicators.unit',
                alias: 'unit'
              },
              {
                column: 'indicators.definition',
                alias: 'definition'
              },
              {
                column: 'indicators.unit',
                alias: 'unit'
              },
              {
                # rubocop:disable Metrics/LineLength
                column: "JSON_AGG(JSON_BUILD_OBJECT('year', time_series_values.year, 'value', ROUND(time_series_values.value, 2)))",
                # rubocop:enable Metrics/LineLength
                alias: 'emissions',
                order: false,
                group: false,
                visible: false
              }
            ]
          end
          # rubocop:enable Metrics/MethodLength
        end
      end
    end
  end
end
