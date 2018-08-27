module Api
  module V1
    module Data
      class ScenariosFilter
        include Api::V1::Data::ColumnHelpers

        # @param params [Hash]
        # @option params [Array<Integer>] :model_ids
        # @option params [Array<Integer>] :scenario_ids
        # @option params [Array<Integer>] :location_ids
        def initialize(params)
          initialize_filters(params)
          @query = Scenario.
            having_time_series.
            includes(:model).
            order(:name)
        end

        def call
          apply_filters
          @query
        end

        private

        def initialize_filters(params)
          # integer arrays
          [
            :location_ids,
            :model_ids,
            :scenario_ids
          ].map do |param_name|
            if params[param_name].present? && params[param_name].is_a?(Array)
              value = params[param_name].map(&:to_i)
            end
            instance_variable_set(:"@#{param_name}", value)
          end
        end

        def apply_filters
          @query = @query.where(id: @scenario_ids) if @scenario_ids
          @query = @query.where(model_id: @model_ids) if @model_ids
          @query = @query.filtered_by_locations(@location_ids) if @location_ids
        end
      end
    end
  end
end
