module Api
  module V1
    class LocationTimeSeriesValuesController < ApiController
      before_action :set_location

      def index
        time_series_values = @location.time_series_values

        if scenario_ids
          time_series_values = time_series_values.
            where(scenario_id: scenario_ids)
        end

        time_series_values = time_series_values.
          group_by(&:indicator_id).
          to_a

        render json: time_series_values,
               each_serializer: Api::V1::LocationTimeSeriesValuesSerializer,
               include_scenario_id: params[:scenario].blank?
      end

      private

      def set_location
        @location = Location.
          includes(:time_series_values).
          find_by!(id: params[:location_id])
      end

      def scenario_ids
        if params[:scenario].blank?
          nil
        else
          params[:scenario].split(',')
        end
      end
    end
  end
end
