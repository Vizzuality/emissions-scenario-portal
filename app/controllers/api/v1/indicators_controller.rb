module Api
  module V1
    class IndicatorsController < ApiController
      def index
        indicators = Indicator.
          includes(category: :parent)

        if params[:category]
          indicators = indicators.where(
            categories: {id: params[:category]}
          ).or(indicators.where(
            categories: {parent_id: params[:category]}
          ))
        end

        indicators = indicators.
          order(:name).
          all

        render json: indicators
      end

      def show
        indicator = Indicator.
          includes(category: :parent).
          find_by!(id: params[:id])

        render json: indicator
      end
    end
  end
end
