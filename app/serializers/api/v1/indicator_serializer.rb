module Api
  module V1
    class IndicatorSerializer < ActiveModel::Serializer
      attribute :id
      attribute :name
      attribute :definition
      attribute :unit
      attribute :composite_name
      attribute :stackable

      belongs_to :category
      belongs_to :subcategory
    end
  end
end
