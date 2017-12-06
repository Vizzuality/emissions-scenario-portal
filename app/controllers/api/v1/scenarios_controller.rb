module Api
  module V1
    class ScenariosController < ApiController
      def index
        scenarios =
          if params[:time_series]
            # FIXME: it seems to be a very inefficient way - it may
            # generate very long queries. It would be better to use
            # GROUP BY and HAVING clauses instead.
            scenarios_ids =
              TimeSeriesValue.
                select(:scenario_id).
                distinct.
                pluck(:scenario_id)
            Scenario.where(id: scenarios_ids)
          else
            Scenario.all
          end

        scenarios = scenarios.where(model_id: params[:model]) if params[:model]
        scenarios = scenarios.includes(:model).order(:name)

        render json: scenarios
      end

      def show
        scenario = Scenario.find_by!(id: params[:id])

        render json: scenario
      end
    end
  end
end
