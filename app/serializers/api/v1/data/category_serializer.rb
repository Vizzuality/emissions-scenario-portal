module Api
  module V1
    module Data
      class CategorySerializer < ActiveModel::Serializer
        attribute :id
        attribute :name
        attribute :parent_id
        attribute :slug

        def slug
          object.name.parameterize
        end
      end
    end
  end
end
