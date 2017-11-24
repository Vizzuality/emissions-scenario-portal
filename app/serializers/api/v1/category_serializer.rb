module Api
  module V1
    class CategorySerializer < ActiveModel::Serializer
      attribute :id
      attribute :name
      attribute :stackable, unless: -> { object.stackable.nil? }

      has_many :subcategories
    end
  end
end

