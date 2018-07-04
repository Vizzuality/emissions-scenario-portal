# Used in ClimateWatch Data Explorer
module Api
  module V1
    module Data
      module EmissionPathways
        class ScenariosController < ApiController
          include Api::V1::ScenariosList

          def index
            render json: @scenarios,
                   adapter: :json,
                   each_serializer: Api::V1::ScenarioSerializer,
                   root: :data
          end
        end
      end
    end
  end
end
