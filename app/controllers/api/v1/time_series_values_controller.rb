module Api
  module V1
    class TimeSeriesValuesController < ApiController
      # rubocop:disable AbcSize
      def index
        values = TimeSeriesValue.includes(:indicator, :scenario).order(:year)
        values = values.where(location_id: location_ids) if location_ids.present?
        values = values.where(scenario_id: scenario_ids) if scenario_ids.present?
        if model_ids.present?
          values = values.joins(:scenario).
            where(scenarios: {model_id: model_ids})
        end

        values = values.where(indicator_id: indicator_ids) if indicator_ids.present?

        render json: values
      end
      # rubocop:enable AbcSize

      private

      def location_ids
        params[:location].to_s.split(',')
      end

      def scenario_ids
        params[:scenario].to_s.split(',')
      end

      def model_ids
        params[:model].to_s.split(',')
      end

      def indicator_ids
        params[:indicator].to_s.split(',')
      end
    end
  end
end
