module Api
  module V1
    module Data
      class EmissionPathwaysFilter
        include Api::V1::Data::SanitisedSorting
        include Api::V1::Data::ColumnHelpers
        attr_reader :years

        # @param params [Hash]
        # @option params [Array<Integer>] :location_ids
        # @option params [Array<Integer>] :model_ids
        # @option params [Array<Integer>] :scenario_ids
        # @option params [Array<Integer>] :category_ids
        # @option params [Array<Integer>] :indicator_ids
        # @option params [Integer] :start_year
        # @option params [Integer] :end_year
        # @option params [String] :sort_col
        # @option params [String] :sort_dir
        def initialize(params)
          initialize_filters(params)
          initialise_sorting(params[:sort_col], params[:sort_dir])
          @query = TimeSeriesValue.
            joins(:location, {scenario: :model}, :indicator).
            joins(
              # rubocop:disable Metrics/LineLength
              'LEFT JOIN categories subcategories ON subcategories.id = indicators.subcategory_id'
              # rubocop:enable Metrics/LineLength
            ).
            joins(
              'LEFT JOIN categories ON categories.id = subcategories.parent_id'
            )
        end

        def call
          apply_filters
          @years = @query.select(:year).distinct.pluck(:year).sort
          @query.
            select(select_columns).
            group(group_columns).
            order(sanitised_order)
        end

        def meta
          {
            years: @years
          }.merge(sorting_manifest).merge(column_manifest)
        end

        private

        # rubocop:disable Metrics/MethodLength
        def select_columns_map
          [
            {
              column: 'indicators.id',
              alias: 'id'
            },
            {
              column: 'locations.iso_code',
              alias: 'iso_code2'
            },
            {
              column: 'locations.name',
              alias: 'location'
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
              column: 'indicators.unit',
              alias: 'unit'
            },
            {
              column: 'indicators.definition',
              alias: 'definition'
            },
            {
              # rubocop:disable Metrics/LineLength
              column: "JSON_AGG(JSON_BUILD_OBJECT('year', time_series_values.year, 'value', ROUND(time_series_values.value, 2)))",
              # rubocop:enable Metrics/LineLength
              alias: 'emissions',
              order: false,
              group: false
            }
          ]
        end
        # rubocop:enable Metrics/MethodLength

        def initialize_filters(params)
          # integer arrays
          [
            :location_ids,
            :model_ids,
            :scenario_ids,
            :indicator_ids,
            :sector_ids,
            :category_ids
          ].map do |param_name|
            if params[param_name].present? && params[param_name].is_a?(Array)
              value = params[param_name].map(&:to_i)
            end
            instance_variable_set(:"@#{param_name}", value)
          end
          @start_year = params[:start_year]
          @end_year = params[:end_year]
        end

        def apply_filters
          if @model_ids
            @query = @query.where('scenarios.model_id' => @model_ids)
          end
          @query = @query.where(scenario_id: @scenario_ids) if @scenario_ids
          @query = @query.where(indicator_id: @indicator_ids) if @indicator_ids
          @query = @query.where(location_id: @location_ids) if @location_ids
          apply_category_filter
          apply_year_filter
        end

        def apply_category_filter
          return unless @category_ids
          top_level_category_ids = Category.top_level.where(id: @category_ids).
            pluck(:id)
          subcategory_ids = @category_ids +
            Category.where(parent_id: top_level_category_ids).pluck(:id)

          @query = @query.where('indicators.subcategory_id' => subcategory_ids)
        end

        # rubocop:disable Style/GuardClause
        def apply_year_filter
          if @start_year
            @query = @query.where('time_series_values.year >= ?', @start_year)
          end
          if @end_year
            @query = @query.where('time_series_values.year <= ?', @end_year)
          end
        end
        # rubocop:enable Style/GuardClause
      end
    end
  end
end
