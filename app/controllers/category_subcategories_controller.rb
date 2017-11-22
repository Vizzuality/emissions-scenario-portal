class CategorySubcategoriesController < ApplicationController
  load_and_authorize_resource :category

  def create
    subcategory = Category.new(subcategory_params)
    subcategory.parent_id = params[:category_id]
    subcategory.save!
    redirect_to(
      edit_category_url(subcategory.parent),
      notice: 'Subcategory successfully added.'
    )
  end

  def destroy
    subcategory = Category.find_by(id: params[:id])
    subcategory.destroy!
    redirect_to(
      edit_category_url(@category),
      notice: 'Subcategory successfully deleted.'
    )
  rescue ActiveRecord::InvalidForeignKey
    redirect_to(
      edit_category_url(@category),
      alert: 'Could not delete subcategory.'
    )
  end

  private

  def set_category
    @category = Category.find(params[:category_id])
  end

  def subcategory_params
    params.require(:category).permit(:name, :stackable)
  end
end
