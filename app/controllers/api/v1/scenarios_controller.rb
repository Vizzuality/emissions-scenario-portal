module Api
  module V1
    class ScenariosController < ApiController
      include Api::V1::ScenariosList

      def index
        render json: @scenarios
      end

      def show
        scenario = Scenario.find_by!(published: true, id: params[:id])

        render json: scenario
      end
    end
  end
end
