module Api
  module V1
    class CategoriesController < ApiController
      def index
        categories = Category.order(:name).all

        render json: categories
      end
    end
  end
end

