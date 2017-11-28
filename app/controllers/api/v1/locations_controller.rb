module Api
  module V1
    class LocationsController < ApiController
      def index
        locations = if params[:time_series]
                      loc_ids = TimeSeriesValue.select(:location_id).distinct
                      Location.where(id: loc_ids.map(&:location_id))
                    else
                      Location.all
                    end
        locations = locations.order(:name)

        render json: locations
      end
    end
  end
end
