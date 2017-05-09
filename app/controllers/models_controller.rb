class ModelsController < ApplicationController
  before_action :set_team
  before_action :set_model, except: [:index]

  def index
    @models = @team.models
    if @models.length == 1
      redirect_to model_url(@models.first) and return
    end
  end

  def show
    @scenarios = @model.scenarios.limit(5)
  end

  def edit
  end

  def update
    if @model.update_attributes(model_params)
      redirect_to model_url(@model)
    else
      render action: :edit
    end
  end

  private

  def set_team
    @team = Team.first # TODO
  end

  def set_model
    @model = Model.find(params[:id])
  end

  def model_params
    params.require(:model).permit(*Model.attribute_symbols_for_strong_params)
  end
end
