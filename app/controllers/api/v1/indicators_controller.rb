module Api
  module V1
    class IndicatorsController < ApiController
      def index

        indicators =
          if params[:time_series]
            Indicator.having_time_series
          else
            Indicator.all
          end

        indicators = indicators.includes(subcategory: :parent)

        if param_list(:category)
          indicators =
            indicators.
              joins(:subcategory).
              where(subcategories: {parent_id: param_list(:category)})
        end

        if param_list(:subcategory)
          indicators = indicators.where(
            subcategory_id: param_list(:subcategory)
          )
        end

        if param_list(:scenario)
          indicator_ids = TimeSeriesValue.select(:indicator_id).
            where(scenario_id: param_list(:scenario)).distinct

          indicators = indicators.where(id: indicator_ids.map(&:indicator_id))
        end

        if param_list(:location)
          indicator_ids = TimeSeriesValue.select(:indicator_id).
            where(location_id: param_list(:location)).distinct

          indicators = indicators.where(id: indicator_ids.map(&:indicator_id))
        end

        if param_list(:model)
          indicators =
            indicators.
              joins(time_series_values: :scenario).
              where(time_series_values: {scenarios: {model_id: param_list(:model)}})
        end

        indicators = indicators.order(:name)

        render json: indicators
      end

      def show
        indicator = Indicator.
          includes(subcategory: :parent).
          find_by!(id: params[:id])

        render json: indicator
      end

      private

      def param_list(param)
        if params[param].blank?
          nil
        else
          params[param].split(',')
        end
      end
    end
  end
end
