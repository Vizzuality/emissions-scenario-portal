module Api
  module V1
    class CategoriesController < ApiController
      def index
        categories =
          Category.
            top_level.
            includes(:subcategories).
            order(:name)

        time_series_conditions = {
          location_id: location_ids,
          scenario_id: scenario_ids
        }.compact

        if time_series_conditions.present?
          categories =
            categories.
              top_level_having_time_series_with(time_series_conditions)
        end

        render json: categories
      end

      private

      def location_ids
        params[:location].to_s.split(',').presence
      end

      def scenario_ids
        params[:scenario].to_s.split(',').presence
      end
    end
  end
end
