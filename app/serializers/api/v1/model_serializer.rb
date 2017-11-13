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

      has_many :scenarios, if: -> { instance_options[:include_relations] }
      has_many :indicators, if: -> { instance_options[:include_relations] }
    end
  end
end
