module Api
  module V1
    class CategorySerializer < ActiveModel::Serializer
      attribute :id
      attribute :name

      has_many :subcategories
    end
  end
end

