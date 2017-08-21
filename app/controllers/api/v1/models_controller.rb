module Api
  module V1
    class ModelsController < ApiController
      def index
        models = Model.all
        render json: models.order(:full_name)
      end

      def show
        model = Model.find_by_id!(params[:id])
        render json: model
      end
    end
  end
end
