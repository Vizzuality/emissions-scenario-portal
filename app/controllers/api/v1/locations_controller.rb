module Api
  module V1
    class LocationsController < ApiController
      def index
        locations = Location.all

        if params[:scenario]
          scenario = Scenario.find(params[:scenario])
          locations = scenario.locations
        elsif params[:time_series]
          locations = Location.having_time_series
        end
        locations = locations.order(:name)

        render json: locations
      end
    end
  end
end
