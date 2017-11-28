module Api
  module V1
    class ScenariosController < ApiController
      def index
        scenarios = if params[:time_series]
                      scenarios_ids = TimeSeriesValue.select(:scenario_id).
                        distinct
                      Scenario.where(id: scenarios_ids.map(&:scenario_id))
                    else
                      Scenario.all
                    end

        scenarios = scenarios.where(model_id: params[:model]) if params[:model]

        scenarios = scenarios.includes(model: :indicators).order(:name)

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
