class ModelsController < ApplicationController
  before_action :set_team

  def index
    @models = @team.models
    if @models.length == 1
      redirect_to model_url(@models.first) and return
    end
  end

  def show
    @model = Model.find(params[:id])
    @scenarios = @model.scenarios.limit(5)
  end

  private

  def set_team
    @team = Team.first # TODO
  end
end
