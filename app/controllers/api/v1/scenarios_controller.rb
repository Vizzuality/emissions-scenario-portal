module Api
  module V1
    class ScenariosController < ApiController
      def index
        scenarios = Scenario.
          includes(:model).
          order(:name)
        scenarios = scenarios.where(model_id: params[:model]) if params[:model]

        render json: scenarios
      end

      def show
        scenario = Scenario.
          find_by!(id: params[:id])

        render json: scenario
      end
    end
  end
end
