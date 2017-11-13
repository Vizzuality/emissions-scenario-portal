module Api
  module V1
    class IndicatorsController < ApiController
      def index
        indicators = Indicator.
          includes(category: :parent).
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
