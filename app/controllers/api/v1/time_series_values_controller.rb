module Api
  module V1
    class TimeSeriesValuesController < ApiController
      # rubocop:disable AbcSize
      def index
        values = TimeSeriesValue.
          includes(:indicator).
          order(:year)
        values = values.where(location_id: location_ids) if location_ids
        values = values.where(scenario_id: scenario_ids) if scenario_ids
        values = values.where(indicators: {model_id: model_ids}) if model_ids
        values = values.where(indicator_id: indicator_ids) if indicator_ids

        render json: values
      end
      # rubocop:enable AbcSize

      private

      def location_ids
        if params[:location].blank?
          nil
        else
          params[:location].split(',')
        end
      end

      def scenario_ids
        if params[:scenario].blank?
          nil
        else
          params[:scenario].split(',')
        end
      end

      def model_ids
        if params[:model].blank?
          nil
        else
          params[:model].split(',')
        end
      end

      def indicator_ids
        if params[:indicator].blank?
          nil
        else
          params[:indicator].split(',')
        end
      end
    end
  end
end
