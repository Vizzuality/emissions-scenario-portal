# Used in ClimateWatch Data Explorer
module Api
  module V1
    module Data
      module EmissionPathways
        class IndicatorsController < ApiController
          include Api::V1::IndicatorsList

          def index
            render json: @indicators,
                   adapter: :json,
                   each_serializer: Api::V1::IndicatorSerializer,
                   root: :data
          end
        end
      end
    end
  end
end
