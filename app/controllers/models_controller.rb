class ModelsController < ApplicationController
  def index
    @models = policy_scope(Model).order(:abbreviation)
    @team = current_user.team
  end

  def new
    @model = Model.new
    @model.team = current_user.team unless current_user.admin?
    authorize(@model)
    render "edit"
  end

  def create
    @model = Model.new(model_params)
    @model.team = current_user.team unless current_user.admin?
    authorize(@model)
    if @model.save
      redirect_to(
        model_path(@model),
        notice: 'Model was successfully created.'
      )
    else
      flash.now[:alert] =
        'We could not create the model. Please check the inputs in red'
      render "edit"
    end
  end

  def edit
    @model = Model.find(params[:id])
    authorize(@model)
  end

  def update
    @model = Model.find(params[:id])
    authorize(@model)
    if @model.update_attributes(model_params)
      redirect_to model_path(@model), notice: 'Model was successfully updated.'
    else
      flash.now[:alert] =
        'We could not update the model. Please check the inputs in red'
      render "edit"
    end
  end

  def show
    @model = Model.find(params[:id])
    authorize(@model)
    @scenarios = @model.scenarios.limit(5)
    @indicators = Indicator.
                    includes(subcategory: :parent).
                    order('categories.name, indicators.name')
  end

  def destroy
    @model = Model.find(params[:id])
    authorize(@model)
    @model.destroy
    redirect_to models_path, notice: 'Model successfully destroyed.'
  end

  private

  def model_params
    params.require(:model).permit(:logo,
                                  *Model.attribute_symbols_for_strong_params)
  end
end
