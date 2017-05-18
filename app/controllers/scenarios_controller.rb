class ScenariosController < ApplicationController
  before_action :set_model, only: [:index]
  before_action :set_scenario, except: [:index]

  def index
    @scenarios = @model.scenarios.fetch_all(scenarios_order_params)
  end

  def edit
    @model = @scenario.model
  end

  def update
    if @scenario.update_attributes(scenario_params)
      redirect_to scenario_url(@scenario)
    else
      render action: :edit
    end
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

  def set_scenario
    @scenario = Scenario.find(params[:id])
  end

  def scenario_params
    params.require(:scenario).permit(
      *Scenario.attribute_symbols_for_strong_params
    )
  end

  def scenarios_order_params
    params.permit(:order_type, :order_direction)
  end
end
