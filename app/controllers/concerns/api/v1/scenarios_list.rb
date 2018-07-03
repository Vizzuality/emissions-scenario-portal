module Api
  module V1
    module ScenariosList
      extend ActiveSupport::Concern

      included do
        before_action :load_scenarios, only: [:index]
      end

      private

      def load_scenarios
        scenarios =
          if params[:time_series]
            Scenario.having_time_series
          else
            Scenario.all
          end

        scenarios = scenarios.where(published: true)
        scenarios = scenarios.where(model_id: params[:model]) if params[:model]
        scenarios = scenarios.includes(:model).order(:name)
        @scenarios = scenarios
      end
    end
  end
end
