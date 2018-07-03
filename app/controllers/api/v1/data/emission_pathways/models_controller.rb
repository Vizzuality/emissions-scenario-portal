# Used in ClimateWatch Data Explorer
module Api
  module V1
    module Data
      module EmissionPathways
        class ModelsController < ApiController
          include Api::V1::ModelsList

          def index
            render json: @models,
                   adapter: :json,
                   each_serializer: Api::V1::ModelSerializer,
                   root: :data
          end
        end
      end
    end
  end
end
