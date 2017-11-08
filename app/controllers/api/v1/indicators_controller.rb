module Api
  module V1
    class IndicatorsController < ApiController
      def index
        indicators = Indicator.
          order(:name).
          all

        render json: indicators
      end
    end
  end
end
