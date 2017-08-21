module Api
  module V1
    class ScenariosController < ApiController
      def index
        model = Model.find(params[:model_id])
        render json: model.scenarios.order(:name)
      end
    end
  end
end
