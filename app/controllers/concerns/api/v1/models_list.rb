module Api
  module V1
    module ModelsList
      extend ActiveSupport::Concern

      included do
        before_action :load_models, only: [:index]
      end

      private

      def load_models
        models = Model.having_published_scenarios.order(:full_name)
        models = models.having_time_series if params[:time_series]
        if location_ids.present?
          models = models.filtered_by_locations(location_ids)
        end
        @models = models
      end

      def location_ids
        if params[:location].blank?
          nil
        else
          params[:location].split(',')
        end
      end
    end
  end
end
