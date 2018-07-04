# Used in ClimateWatch Data Explorer
module Api
  module V1
    module Data
      module EmissionPathways
        class CategoriesController < ApiController
          def index
            @categories = Category.all

            render json: @categories,
                   adapter: :json,
                   each_serializer: Api::V1::Data::CategorySerializer,
                   root: :data
          end
        end
      end
    end
  end
end
