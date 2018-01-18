module Api
  module V1
    class IndicatorSerializer < ActiveModel::Serializer
      attribute :id
      attribute :name
      attribute :definition
      attribute :unit
      attribute :composite_name

      belongs_to :category
      belongs_to :subcategory

      def category
        category = object.subcategory.parent
        {id: category&.id, name: category&.name}
      end
    end
  end
end
