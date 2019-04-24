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
              from('searchable_time_series_values time_series_values').
              all
            @years_query = TimeSeriesValue.
              joins(scenario: :model).
              all
          end

          def call
            @query = apply_filters(@query, mview: true)
            @years_query = apply_filters(@years_query, mview: false)
            @years = @years_query.distinct(:year).pluck(:year).sort.reverse
            @header_years = @years.dup
            @header_years.reject! { |y| y < @start_year } if @start_year
            @header_years.reject! { |y| y > @end_year } if @end_year
            @query.
              select(select_columns).
              order(sanitised_order)
          end

          def year_value_column(year)
            Arel.sql("emissions_dict->'#{year}'")
          end

          def meta
            {
              years: @years,
              header_years: @header_years
            }.merge(sorting_manifest).merge(column_manifest)
          end

          private

          # rubocop:disable Metrics/AbcSize
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
            @start_year = params[:start_year]&.to_i
            unless @start_year.present? && @start_year > MINIMUM_YEAR_FROM
              @start_year = MINIMUM_YEAR_FROM
            end
            @end_year = params[:end_year]&.to_i
          end
          # rubocop:enable Metrics/AbcSize
          # rubocop:enable Metrics/MethodLength

          # rubocop:disable Metrics/CyclomaticComplexity
          # rubocop:disable Metrics/PerceivedComplexity
          def apply_filters(query, options)
            if @model_ids && options[:mview]
              query = query.where(model_id: @model_ids)
            elsif @model_ids
              query = query.where('scenarios.model_id' => @model_ids)
            end
            query = query.where(scenario_id: @scenario_ids) if @scenario_ids
            query = query.where(indicator_id: @indicator_ids) if @indicator_ids
            query = query.where(location_id: @location_ids) if @location_ids
            query = query.joins(:indicator).where(indicators: {subcategory_id: apply_category_filter}) if @category_ids
            puts query.to_sql.inspect
            query
          end
          # rubocop:enable Metrics/CyclomaticComplexity
          # rubocop:enable Metrics/PerceivedComplexity

          def apply_category_filter
            top_level_category_ids = Category.top_level.
              where(id: @category_ids).
              pluck(:id)
            subcategory_ids = @category_ids +
              Category.where(parent_id: top_level_category_ids).pluck(:id)

            subcategory_ids
          end
        end
      end
    end
  end
end
