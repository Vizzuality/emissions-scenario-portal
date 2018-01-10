class SubcategoriesController < ApplicationController
  def create
    category = Category.find(params[:category_id])
    subcategory = category.subcategories.build(subcategory_params)
    subcategory.parent_id = params[:category_id]
    authorize(subcategory)
    subcategory.save!
    redirect_to(
      edit_category_path(category),
      notice: 'Subcategory successfully added.'
    )
  end

  def destroy
    category = Category.find(params[:category_id])
    subcategory = category.subcategories.find(params[:id])
    authorize(subcategory)
    subcategory.destroy
    redirect_to(
      edit_category_path(category),
      alert: subcategory.errors[:base].first
    )
  end

  private

  def subcategory_params
    params.require(:category).permit(:name, :stackable)
  end
end
