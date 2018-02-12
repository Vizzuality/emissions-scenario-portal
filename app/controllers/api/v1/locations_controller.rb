module Api
  module V1
    class LocationsController < ApiController
      def index
        locations = Location.order(:name)
        if params[:scenario]
          locations = Location.having_time_series.where(
            time_series_values: {scenario_id: params[:scenario]}
          )
        elsif params[:time_series]
          locations = Location.having_time_series
        end

        render json: locations
      end
    end
  end
end
