class ScenariosController < ApplicationController
  before_action :set_model, only: [:index]

  def index
    @scenarios = @model.scenarios.fetch_all(scenarios_order_params)
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

  def scenarios_order_params
    params.permit(:order_type, :order_direction)
  end
end
