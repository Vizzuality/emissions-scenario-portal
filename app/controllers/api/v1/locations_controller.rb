module Api
  module V1
    class LocationsController < ApiController
      def index
        locations =
          if params[:time_series]
            Location.having_time_series
          else
            Location.all
          end
        locations = locations.order(:name)

        render json: locations
      end
    end
  end
end
