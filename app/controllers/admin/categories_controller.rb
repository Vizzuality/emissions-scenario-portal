module Admin
  class CategoriesController < AdminController
    load_and_authorize_resource
    before_action :set_filter_params, only: [:index]

    def index
      @categories = Category.fetch_all(@filter_params)
    end

    def new
      @category = Category.new
      @parent_categories = Category.where(parent_id: nil)
      render :edit
    end

    def edit
      @parent_categories = Category.where(parent_id: nil)
    end

    def create
      @category = Category.new(category_params)

      if @category.save
        redirect_to edit_category_url(@category),
          notice: 'Category was successfully created.'
      else
        flash[:alert] =
          'We could not create the category. Please check the inputs in red'
        render :edit
      end
    end

    def update
      if @category.update_attributes(category_params)
        redirect_to edit_category_url(@category),
          notice: 'Category was successfully updated.'
      else
        flash[:alert] =
          'We could not update the category. Please check the inputs in red'
        render :edit
      end
    end

    def destroy
      @category.destroy
      redirect_to categories_url,
        notice: 'Category was successfully destroyed.'
    rescue ActiveRecord::InvalidForeignKey
      redirect_to(
        categories_url,
        alert: 'Could not delete category.'
      )
    end

    private

    def category_params
      params.require(:category).permit(
        :name, subcategories_attributes: [
          :id, :name, :stackable
        ])
    end
  end
end
