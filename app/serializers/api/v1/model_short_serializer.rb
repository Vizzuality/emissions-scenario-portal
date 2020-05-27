module Api
  module V1
    class ModelShortSerializer < ActiveModel::Serializer
      attribute :id
      attribute :full_name, key: :name
      attribute :logo
      attribute :slug

      def slug
        object.full_name.parameterize
      end

      def logo
        object.logo_file_name ?
          object.logo.url(:original) :
          object.team && object.team.image_file_name && object.team.image.url(:original)
      end
    end
  end
end
