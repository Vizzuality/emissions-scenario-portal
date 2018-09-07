module Api
  module V1
    module Data
      module EmissionPathways
        class Filter
          include Api::V1::Data::SanitisedSorting
          include Api::V1::Data::ColumnHelpers
          include Api::V1::Data::EmissionPathways::FilterColumns
          attr_reader :header_years

          MINIMUM_YEAR_FROM = 2005

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
                # rubocop:disable Metrics/LineLength
                'LEFT JOIN categories ON categories.id = subcategories.parent_id'
                # rubocop:enable Metrics/LineLength
              )
          end

          # rubocop:disable Metrics/AbcSize
          def call
            apply_minimum_year_from
            apply_filters
            @years = @query.select(:year).distinct.pluck(:year).sort
            @header_years = @years.dup
            @header_years.reject! { |y| y < @start_year } if @start_year
            @header_years.reject! { |y| y > @end_year } if @end_year
            apply_year_filter
            @query.
              select(select_columns).
              group(group_columns).
              order(sanitised_order)
          end
          # rubocop:enable Metrics/AbcSize

          def meta
            {
              years: @years,
              header_years: @header_years
            }.merge(sorting_manifest).merge(column_manifest)
          end

          private

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
            @start_year = params[:start_year]&.to_i
            @end_year = params[:end_year]&.to_i
          end

          def apply_filters
            if @model_ids
              @query = @query.where('scenarios.model_id' => @model_ids)
            end
            @query = @query.where(scenario_id: @scenario_ids) if @scenario_ids
            if @indicator_ids
              @query = @query.where(indicator_id: @indicator_ids)
            end
            @query = @query.where(location_id: @location_ids) if @location_ids
            apply_category_filter
          end

          def apply_category_filter
            return unless @category_ids
            top_level_category_ids = Category.top_level.
              where(id: @category_ids).
              pluck(:id)
            subcategory_ids = @category_ids +
              Category.where(parent_id: top_level_category_ids).pluck(:id)

            @query = @query.where(
              'indicators.subcategory_id' => subcategory_ids
            )
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

          def apply_minimum_year_from
            @query = @query.
              where('time_series_values.year >= ?', MINIMUM_YEAR_FROM)
          end
          # rubocop:enable Style/GuardClause
        end
      end
    end
  end
end