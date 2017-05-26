class ModelsController < ApplicationController
  load_and_authorize_resource

  before_action :set_nav_links, only: [:index, :show, :edit]

  def index
    redirect_to model_url(@models.first) and return if @models.length == 1
  end

  def show
    @scenarios = @model.scenarios.limit(5)
    @indicators = Indicator.order(:category, :stack_family, :name)
  end

  def edit; end

  def update
    if @model.update_attributes(model_params)
      redirect_to model_url(@model)
    else
      render action: :edit
    end
  end

  def upload_meta_data
    # TODO: implement
  end

  private

  def model_params
    params.require(:model).permit(*Model.attribute_symbols_for_strong_params)
  end
end
