class ScenariosController < ApplicationController
  def index
    @model = Model.find(params[:model_id])
    @scenarios =
      FilterScenarios.
        new(filter_params).
        call(policy_scope(@model.scenarios))
  end

  def show
    @model = Model.find(params[:model_id])
    @scenario = @model.scenarios.find(params[:id])
    authorize(@scenario)
    @indicators = FilterIndicators.
      new(@filter_params).
      call(@scenario.indicators)
  end

  def edit
    @model = Model.find(params[:model_id])
    @scenario = @model.scenarios.find(params[:id])
    authorize(@scenario)
  end

  def update
    @model = Model.find(params[:model_id])
    @scenario = @model.scenarios.find(params[:id])
    authorize(@scenario)
    if @scenario.update_attributes(scenario_params)
      redirect_to model_scenario_path(@model, @scenario),
                  notice: 'Scenario was successfully updated.'
    else
      flash[:alert] =
        'We could not update the scenario. Please check the inputs in red'
      render action: :edit
    end
  end

  def destroy
    @model = Model.find(params[:model_id])
    @scenario = @model.scenarios.find(params[:id])
    @scenario.destroy
    authorize(@scenario)
    redirect_to(
      model_scenarios_path(@model),
      notice: 'Scenario successfully destroyed.'
    )
  end

  private

  def scenario_params
    params.require(:scenario).permit(
      *Scenario.attribute_symbols_for_strong_params
    )
  end

  def filter_params
    params.permit(:search, :order_type, :order_direction)
  end
end
