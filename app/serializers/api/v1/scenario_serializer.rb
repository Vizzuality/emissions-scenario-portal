module Api
  module V1
    class ScenarioSerializer < ActiveModel::Serializer
      attributes :id, :name
    end
  end
end
