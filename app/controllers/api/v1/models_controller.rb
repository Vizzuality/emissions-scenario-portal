module Api
  module V1
    class ModelsController < ApplicationController
      skip_before_action :authenticate_user!

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
