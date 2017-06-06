class ModelsController < ApplicationController
  load_and_authorize_resource

  before_action :set_nav_links, only: [:index, :show, :edit]

  def index
    redirect_to model_url(@models.first) and return if @models.length == 1
  end

  def new
    @model = Model.new
    @model.team = current_user.team unless current_user.admin?
    render action: :edit
  end

  def create
    @model = Model.new(model_params)
    @model.team = current_user.team unless current_user.admin?
    if @model.save
      redirect_to(
        model_url(@model),
        notice: 'Model was successfully created.'
      )
    else
      flash[:alert] =
        'We could not create the model. Please check the inputs in red'
      render action: :edit
    end
  end

  def edit; end

  def update
    if @model.update_attributes(model_params)
      redirect_to model_url(@model), notice: 'Model was successfully updated.'
    else
      set_nav_links
      flash[:alert] =
        'We could not update the model. Please check the inputs in red'
      render action: :edit
    end
  end

  def show
    @scenarios = @model.scenarios.limit(5)
    @indicators = Indicator.order(:category, :subcategory, :name)
  end

  def upload_meta_data
    # TODO: implement
  end

  private

  def model_params
    params.require(:model).permit(*Model.attribute_symbols_for_strong_params)
  end
end
