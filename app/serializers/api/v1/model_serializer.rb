module Api
  module V1
    class ModelSerializer < ActiveModel::Serializer
      attributes :id, :full_name
      has_many :scenarios
    end
  end
end
