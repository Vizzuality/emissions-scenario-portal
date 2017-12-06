module Api
  module V1
    class ModelsController < ApiController
      def index
        models =
          if params[:time_series]
            Model.have_time_series
          else
            Model.all
          end

        models = models.
          filtered_by_locations(location_ids) if location_ids.present?
        models = models.with_scenarios_and_indicators
        models = models.order(:full_name)

        render json: models
      end

      def show
        model = Model.
          includes(:scenarios).
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
