module Api
  module V1
    class IndicatorSerializer < ActiveModel::Serializer
      attribute :id
      attribute :name
      attribute :definition
      attribute :unit
      attribute :subcategory
      attribute :stackable_subcategory
      attribute :unit_of_entry
      attribute :conversion_factor
      attribute :alias
      attribute :auto_generated
      attribute :model_id
      attribute :parent_id

      belongs_to :category
      belongs_to :subcategory

      def category
        if object.category.parent
          object.category.parent
        else
          object.category
        end
      end

      def subcategory
        if object.category.parent
          object.category
        end
      end
    end
  end
end
