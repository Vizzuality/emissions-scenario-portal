module Api
  module V1
    class ScenariosController < ApiController
      def index
        scenarios =
          if params[:time_series]
            Scenario.having_time_series
          else
            Scenario.all
          end

        scenarios = scenarios.where(published: true)
        scenarios = scenarios.where(model_id: params[:model]) if params[:model]
        scenarios = scenarios.includes(:model).order(:name)

        render json: scenarios
      end

      def show
        scenario = Scenario.find_by!(published: true, id: params[:id])

        render json: scenario
      end
    end
  end
end
