module Api
  module V1
    class IndicatorsController < ApiController
      include Api::V1::IndicatorsList

      def index
        render json: @indicators
      end

      def show
        indicator = Indicator.
          includes(subcategory: :parent).
          find_by!(id: params[:id])

        render json: indicator
      end
    end
  end
end
