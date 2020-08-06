module Api
  module V1
    class IndicatorSerializer < ActiveModel::Serializer
      attribute :id
      attribute :name
      attribute :definition
      attribute :unit
      attribute :composite_name
      attribute :stackable
      attribute :slug

      belongs_to :category
      belongs_to :subcategory

      def slug
        object.name.parameterize
      end
    end
  end
end
