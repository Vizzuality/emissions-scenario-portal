module Api
  module V1
    class ModelsController < ApiController
      def index
        if location_ids.blank?
          models = Model.
              includes(:scenarios, :indicators).
              order(:full_name)
        else
          models = Model.
            joins({indicators: {time_series_values: :location}}, :scenarios).
            where(indicators: {time_series_values: {location_id: location_ids}}).
            order(:full_name).distinct
        end

        puts models.count
        models.each {|x| puts x.id}
        render json: models
      end

      def show
        model = Model.
          includes(:scenarios, :indicators).
          find_by!(id: params[:id])

        render json: model
      end

      private

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
