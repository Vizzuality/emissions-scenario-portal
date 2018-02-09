module Api
  module V1
    class TimeSeriesValuesController < ApiController
      def index
        conditions = {
          location_id: params[:location].to_s.split(',').presence,
          scenario_id: params[:scenario].to_s.split(',').presence,
          indicator_id: params[:indicator].to_s.split(',').presence,
          scenarios: {
            model_id: params[:model].to_s.split(',').presence
          }.compact.presence
        }.compact

        tsvs =
          TimeSeriesValue.
            includes(:scenario).
            order(:year).
            where(conditions)

        if params[:year_from].present?
          tsvs = tsvs.where("year >= ?", params[:year_from])
        end

        if params[:year_to].present?
          tsvs = tsvs.where("year <= ?", params[:year_to])
        end

        render(json: tsvs)
      end
    end
  end
end
