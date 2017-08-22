module Api
  module V1
    class ModelsController < ApiController
      def index
        models = Model.includes(:scenarios).all
        render json: models.order(:full_name)
      end

      def show
        model = Model.includes(:scenarios).find(params[:id])
        render json: model
      end
    end
  end
end
