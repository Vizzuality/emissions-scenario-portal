class ScenariosController < ApplicationController
  before_action :set_model

  def index
    @scenarios = @model.scenarios
  end

  private

  def set_model
    @model = Model.find(params[:model_id])
  end
end
