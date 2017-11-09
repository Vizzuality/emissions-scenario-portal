module Api
  module V1
    class ModelsController < ApiController
      def index
        models = Model.
          order(:full_name)

        render json: models
      end

      def show
        model = Model.
          includes(:scenarios, :indicators).
          find_by!(id: params[:id])

        render json: model, include_relations: true
      end
    end
  end
end
