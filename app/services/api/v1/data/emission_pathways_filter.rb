module Api
  module V1
    module Data
      class EmissionPathwaysFilter
        attr_reader :years

        # @param params [Hash]
        # @option params [Array<Integer>] :location_ids
        # @option params [Array<Integer>] :model_ids
        # @option params [Array<Integer>] :scenario_ids
        # @option params [Array<Integer>] :category_ids
        # @option params [Array<Integer>] :indicator_ids
        # @param start_year [Integer]
        # @param end_year [Integer]
        def initialize(params)
          initialize_filters(params)
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
            group(group_columns)
        end

        def column_aliases
          column_aliases = select_columns_with_aliases.
            map do |column, column_alias|
              column_alias || column
            end
          column_aliases.pop # pop emissions, this is for csv
          column_aliases
        end

        private

        def select_columns
          select_columns_with_aliases.map do |column, column_alias|
            if column_alias
              [column, 'AS', column_alias].join(' ')
            else
              column
            end
          end
        end

        def group_columns
          columns = select_columns_with_aliases.map(&:first)
          columns[0..columns.length - 2]
        end

        # rubocop:disable Metrics/MethodLength
        def select_columns_with_aliases
          [
            ['indicators.id', 'id'],
            ['locations.iso_code', 'iso_code2'],
            ['locations.name', 'location'],
            ['models.full_name', 'model'],
            ['scenarios.name', 'scenario'],
            ['categories.name', 'category'],
            ['subcategories.name', 'subcategory'],
            ['indicators.name', 'indicator'],
            ['indicators.unit', 'unit'],
            ['indicators.definition', 'definition'],
            [
              # rubocop:disable Metrics/LineLength
              "JSON_AGG(JSON_BUILD_OBJECT('year', time_series_values.year, 'value', ROUND(time_series_values.value, 2)))",
              # rubocop:enable Metrics/LineLength
              'emissions'
            ]
          ]
        end
        # rubocop:enable Metrics/MethodLength

        # rubocop:disable Metrics/MethodLength
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
        # rubocop:enable Metrics/MethodLength

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
