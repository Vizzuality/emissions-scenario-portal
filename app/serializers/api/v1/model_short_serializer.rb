module Api
  module V1
    class ModelShortSerializer < ActiveModel::Serializer
      attribute :id
      attribute :full_name, key: :name
    end
  end
end
