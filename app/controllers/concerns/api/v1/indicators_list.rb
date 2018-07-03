module Api
  module V1
    module IndicatorsList
      extend ActiveSupport::Concern

      included do
        before_action :load_indicators, only: [:index]
      end

      private

      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/CyclomaticComplexity
      # rubocop:disable Metrics/MethodLength
      # rubocop:disable Metrics/PerceivedComplexity
      def load_indicators
        indicators =
          if params[:time_series]
            Indicator.having_time_series
          else
            Indicator.all
          end

        indicators = indicators.includes(subcategory: :parent)

        if params[:stackable]
          indicators = indicators.where(stackable: params[:stackable])
        end

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

        time_series_conditions = {
          scenario_id: param_list(:scenario),
          location_id: param_list(:location)
        }.compact

        if time_series_conditions.present?
          indicators = indicators.having_time_series_with(
            time_series_conditions
          )
        end

        if param_list(:model)
          indicators =
            indicators.
              joins(time_series_values: :scenario).
              where(
                time_series_values: {scenarios: {model_id: param_list(:model)}}
              )
        end

        indicators = indicators.order(:name)
        @indicators = indicators
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/CyclomaticComplexity
      # rubocop:enable Metrics/MethodLength
      # rubocop:enable Metrics/PerceivedComplexity

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
