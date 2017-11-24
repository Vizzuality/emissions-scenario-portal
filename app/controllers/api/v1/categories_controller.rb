module Api
  module V1
    class CategoriesController < ApiController
      def index
        categories = Category.
          where(parent_id: nil).
          includes(:subcategories).
          order(:name).
          all

        render json: categories
      end
    end
  end
end

