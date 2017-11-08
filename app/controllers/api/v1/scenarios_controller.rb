module Api
  module V1
    class ScenariosController < ApiController
      def index
        scenarios = Scenario.
          order(:name)
        scenarios = scenarios.where(model_id: params[:model]) if params[:model]

        render json: scenarios
      end
    end
  end
end
