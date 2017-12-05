module Api
  module V1
    class TimeSeriesValueSerializer < ActiveModel::Serializer
      attribute :id
      attribute :year
      attribute :value
      attribute :scenario_id
      attribute :indicator_id
      attribute :location_id
      attribute :model_id

      def model_id
        object.scenario.model_id
      end
    end
  end
end
