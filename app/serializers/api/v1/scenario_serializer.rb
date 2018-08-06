module Api
  module V1
    class ScenarioSerializer < ActiveModel::Serializer
      attribute :id
      attribute :model_abbreviation
      attribute :name
      attribute :year
      attribute :category
      attribute :purpose_or_objective
      attribute :description
      attribute :reference
      attribute :url
      attribute :policy_coverage
      attribute :technology_coverage
      attribute :socioeconomics
      attribute :climate_target
      attribute :other_target
      attribute :burden_sharing
      attribute :discount_rates

      belongs_to :model
      has_many :indicator_ids
      has_many :category_ids

      def model
        {
          id: object.model.id,
          name: object.model.full_name
        }
      end

      def indicator_ids
        object.indicators.pluck(:id)
      end

      def category_ids
        object.categories.pluck(:id)
      end
    end
  end
end
