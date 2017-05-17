class ScenariosController < ApplicationController
  before_action :set_model, only: [:index]

  def index
    @scenarios = @model.scenarios
  end

  def show
    @scenario = Scenario.find(params[:id])
  end

  def upload_meta_data
    #  TODO: implement
  end

  private

  def set_model
    @model = Model.find(params[:model_id])
  end
end
