module Api
  module V1
    class CategorySerializer < ActiveModel::Serializer
      attribute :id
      attribute :name

      attribute :parent_id, unless: -> { object.parent.nil? }
      has_many :subcategories, if: -> { object.parent.nil? }
    end
  end
end

