module Api
  module V1
    class LocationsController < ApiController
      def index
        locations = Location.order(:name).all
        render json: locations
      end
    end
  end
end
