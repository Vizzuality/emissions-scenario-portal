module Api
  module V1
    class ModelsController < ApiController
      def index
        models = Model.
          includes(:scenarios).
          order(:full_name)

        render json: models
      end

      def show
        model = Model.
          includes(:scenarios).
          find_by!(id: params[:id])

        render json: model
      end
    end
  end
end
