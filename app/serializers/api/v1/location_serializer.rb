module Api
  module V1
    class LocationSerializer < ActiveModel::Serializer
      attribute :id
      attribute :name
      attribute :iso_code
      attribute :region
    end
  end
end
