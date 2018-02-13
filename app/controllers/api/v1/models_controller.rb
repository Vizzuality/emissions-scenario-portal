module Api
  module V1
    class ModelsController < ApiController
      def index
        models = Model.having_published_scenarios.order(:full_name)
        models = models.having_time_series if params[:time_series]

        models = models.filtered_by_locations(location_ids) if location_ids.present?

        render json: models
      end

      def show
        model =
          Model.
            having_published_scenarios.
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
