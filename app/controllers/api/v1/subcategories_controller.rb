module Api
  module V1
    class SubcategoriesController < ApiController
      def index
        categories =
          Category.
            second_level.
            order(:name)

        categories =
          categories.where(
            {parent_id: params[:category].to_s.split(',').presence}.compact
          )

        time_series_conditions = {
          location_id: params[:location].to_s.split(',').presence,
          scenario_id: params[:scenario].to_s.split(',').presence
        }.compact

        if time_series_conditions.present?
          categories =
            categories.
              second_level_having_time_series_with(time_series_conditions)
        end

        render json: categories
      end
    end
  end
end
