class CategoriesController < ApplicationController
  def index
    @categories =
      FilterCategories.
        new(filter_params).
        call(
          policy_scope(Category).
            top_level.
            includes(:subcategories)
        )
  end

  def new
    @category = Category.new
    authorize(@category)
    @parent_categories = Category.top_level
    render :edit
  end

  def create
    @category = Category.new(category_params)
    authorize(@category)
    if @category.save
      redirect_to edit_category_path(@category),
                  notice: 'Category was successfully created.'
    else
      flash.now[:alert] =
        'We could not create the category. Please check the inputs in red'
      render :edit
    end
  end

  def edit
    @category = Category.find(params[:id])
    authorize(@category)
    @parent_categories = Category.top_level
  end

  def update
    @category = Category.find(params[:id])
    authorize(@category)
    if @category.update_attributes(category_params)
      redirect_to edit_category_path(@category),
                  notice: 'Category was successfully updated.'
    else
      flash.now[:alert] =
        'We could not update the category. Please check the inputs in red'
      render :edit
    end
  end

  def destroy
    @category = Category.find(params[:id])
    authorize(@category)
    @category.destroy
    redirect_to(
      categories_path,
      alert: @category.errors.full_messages_for(:base).first
    )
  end

  private

  def category_params
    params.require(:category).permit(
      :name, subcategories_attributes: %i[id name]
    )
  end

  def filter_params
    params.permit(:search, :order_type, :order_direction)
  end
end
