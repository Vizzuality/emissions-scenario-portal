module Api
  module V1
    class LocationTimeSeriesValuesSerializer < ActiveModel::Serializer
      attribute :indicator_id
      attribute :values

      def indicator_id
        object.first
      end

      def values
        object.second.map do |tsv|
          {
            year: tsv.year,
            value: tsv.value,
            scenario_id: tsv.scenario_id
          }
        end
      end
    end
  end
end
