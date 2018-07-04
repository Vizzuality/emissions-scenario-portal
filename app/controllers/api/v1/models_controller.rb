module Api
  module V1
    class ModelsController < ApiController
      include Api::V1::ModelsList

      def index
        render json: @models
      end

      def show
        model =
          Model.
            having_published_scenarios.
            includes(:scenarios).
            find_by!(id: params[:id])

        render json: model
      end
    end
  end
end
