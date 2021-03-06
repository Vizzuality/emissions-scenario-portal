# Used in ClimateWatch Data Explorer
module Api
  module V1
    module Data
      module EmissionPathways
        class LocationsController < ApiController
          def index
            @locations = Location.all
            @locations = @locations.having_time_series if params[:time_series]

            render json: @locations,
                   adapter: :json,
                   each_serializer: Api::V1::LocationSerializer,
                   root: :data
          end
        end
      end
    end
  end
end
