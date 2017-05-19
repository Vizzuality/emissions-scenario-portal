class ScenariosController < ApplicationController
  before_action :set_model, :set_nav_links
  before_action :set_scenario, except: [:index]

  def index
    @scenarios = @model.scenarios.fetch_all(scenarios_order_params)
  end

  def edit; end

  def update
    if @scenario.update_attributes(scenario_params)
      redirect_to model_scenario_url(@model, @scenario)
    else
      render action: :edit
    end
  end

  def show; end

  def destroy
    @scenario = Scenario.find(params[:id])
    @scenario.destroy
    redirect_to(
      model_scenarios_url(@model),
      notice: 'Scenario successfully destroyed.'
    )
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
