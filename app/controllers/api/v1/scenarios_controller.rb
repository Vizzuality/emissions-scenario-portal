module Api
  module V1
    class ScenariosController < ApplicationController
      skip_before_action :authenticate_user!

      def index
        model = Model.find(params[:model_id])
        render json: model.scenarios.order(:name)
      end
    end
  end
end
