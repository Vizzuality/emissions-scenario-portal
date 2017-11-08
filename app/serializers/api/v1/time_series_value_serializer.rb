module Api
  module V1
    class TimeSeriesValueSerializer < ActiveModel::Serializer
      attribute :id
      attribute :year
      attribute :value
      attribute :unit_of_entry
      attribute :conversion_factor, if: -> { !object.conversion_factor.nil? }
      attribute :scenario_id
      attribute :indicator_id
      attribute :location_id
    end
  end
end
