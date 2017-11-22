module Api
  module V1
    class IndicatorSerializer < ActiveModel::Serializer
      attribute :id
      attribute :name
      attribute :definition
      attribute :unit
      attribute :unit_of_entry
      attribute :conversion_factor
      attribute :alias
      attribute :auto_generated
      attribute :parent_id

      belongs_to :model, serializer: Api::V1::ModelShortSerializer
      belongs_to :category
      belongs_to :subcategory
    end
  end
end
