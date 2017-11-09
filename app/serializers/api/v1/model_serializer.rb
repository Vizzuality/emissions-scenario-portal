module Api
  module V1
    class ModelSerializer < ActiveModel::Serializer
      attribute :id
      attribute :full_name
      has_many :scenarios, if: -> { instance_options[:include_relations] }
      has_many :indicators, if: -> { instance_options[:include_relations] }
    end
  end
end
