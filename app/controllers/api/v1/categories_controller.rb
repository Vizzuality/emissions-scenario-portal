module Api
  module V1
    class CategoriesController < ApiController
      def index
        categories = Category.
          where(parent_id: nil).
          includes(:subcategories).
          order(:name)

        if location_ids.present?
          categories = categories.having_time_series_with(location_id: location_ids)
        end

        if scenario_ids.present?
          categories = categories.having_time_series_with(scenario_id: scenario_ids)
        end

        render json: categories
      end

      private

      def location_ids
        params[:location].to_s.split(',')
      end

      def scenario_ids
        params[:scenario].to_s.split(',')
      end
    end
  end
end
