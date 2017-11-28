module Api
  module V1
    class ModelsController < ApiController
      def index
        models = if location_ids.present?
                   Model.filtered_by_locations(location_ids)
                 elsif params[:time_series]
                   Model.have_time_series
                 else
                   Model.with_scenarios_and_indicators
                 end
        models = models.order(:full_name)

        render json: models
      end

      def show
        model = Model.
          includes(:scenarios, :indicators).
          find_by!(id: params[:id])

        render json: model
      end

      private

      def location_ids
        if params[:location].blank?
          nil
        else
          params[:location].split(',')
        end
      end
    end
  end
end
