class ScenariosController < ApplicationController
  before_action :set_model
  before_action :set_scenario, except: [:index]
  before_action :set_nav_links, only: [:index, :show, :edit]
  before_action :set_filter_params, only: [:index, :show]

  def index
    @scenarios = @model.scenarios.fetch_all(@filter_params)
  end

  def edit; end

  def update
    if @scenario.update_attributes(scenario_params)
      redirect_to model_scenario_url(@model, @scenario)
    else
      render action: :edit
    end
  end

  def show
    @indicators = @scenario.indicators.fetch_all(@filter_params)
  end

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
end
