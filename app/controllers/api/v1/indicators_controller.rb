module Api
  module V1
    class IndicatorsController < ApiController
      def index

        indicators = if params[:time_series]
                       ind_ids = TimeSeriesValue.select(:indicator_id).distinct
                       Indicator.where(id: ind_ids.map(&:indicator_id))
                     else
                       Indicator.all
                     end

        indicators = Indicator.
          includes(:category, :subcategory, :model)

        if param_list(:category)
          indicators = indicators.where(
            category_id: param_list(:category)
          )
        end

        if param_list(:subcategory)
          indicators = indicators.where(
            subcategory_id: param_list(:subcategory)
          )
        end

        if param_list(:scenario)
          indicator_ids = Scenario.where(id: param_list(:scenario)).
            includes(:time_series_values).
            flat_map(&:time_series_values).
            map(&:indicator_id).
            uniq

          indicators = indicators.where(id: indicator_ids)
        end

        if param_list(:location)
          indicator_ids = Location.where(id: param_list(:location)).
            includes(:time_series_values).
            flat_map(&:time_series_values).
            map(&:indicator_id).
            uniq

          indicators = indicators.where(id: indicator_ids)
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
