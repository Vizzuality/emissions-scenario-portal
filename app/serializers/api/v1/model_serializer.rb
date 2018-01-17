module Api
  module V1
    class ModelSerializer < ActiveModel::Serializer
      attribute :id
      attribute :full_name
      attribute :description
      attribute :key_usage
      attribute :abbreviation
      attribute :current_version
      attribute :development_year
      attribute :programming_language
      attribute :maintainer_name
      attribute :license
      attribute :availability
      attribute :expertise
      attribute :expertise_detailed
      attribute :platform_detailed
      attribute :purpose_or_objective
      attribute :time_step
      attribute :time_horizon
      attribute :sectoral_coverage

      has_many :scenarios
      has_many :indicators

      def indicators
        object.indicators.pluck(:id)
      end
    end
  end
end
