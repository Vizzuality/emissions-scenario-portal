module Api
  module V1
    module Data
      class CategorySerializer < ActiveModel::Serializer
        attribute :id
        attribute :name
        attribute :parent_id
      end
    end
  end
end
