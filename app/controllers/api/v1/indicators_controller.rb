module Api
  module V1
    class IndicatorsController < ApiController
      def index
        indicators = Indicator.
          order(:name).
          all

        render json: indicators
      end

      def show
        indicator = Indicator.
          find_by!(id: params[:id])

        render json: indicator
      end
    end
  end
end
