module Api
  module V1
    class IndicatorSerializer < ActiveModel::Serializer
      attribute :id
      attribute :category
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
    end
  end
end
