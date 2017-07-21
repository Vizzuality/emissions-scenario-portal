require 'scenarios_upload_template'

class ScenariosController < ApplicationController
  load_and_authorize_resource :model
  load_and_authorize_resource through: :model, except: [:index]
  authorize_resource only: [:index]

  before_action :set_nav_links, only: [:index, :show, :edit]
  before_action :set_filter_params, only: [:index, :show]

  def index
    @scenarios = @model.scenarios.fetch_all(@filter_params)
  end

  def edit; end

  def update
    if @scenario.update_attributes(scenario_params)
      redirect_to model_scenario_url(@model, @scenario),
                  notice: 'Scenario was successfully updated.'
    else
      flash[:alert] =
        'We could not update the scenario. Please check the inputs in red'
      render action: :edit
    end
  end

  def show
    @indicators = @scenario.indicators.fetch_all(@filter_params)
    @indicator_categories = Indicator.except(:order).
      order(:category).
      distinct.pluck(:category)
  end

  def destroy
    @scenario.destroy
    redirect_to(
      model_scenarios_url(@model),
      notice: 'Scenario successfully destroyed.'
    )
  end

  def upload_meta_data
    handle_io_upload(:scenarios_file, model_scenarios_url(@model)) do
      UploadScenarios.new(current_user, @model).call(@uploaded_io)
    end and return
    index
    render action: :index
  end

  def upload_template
    csv_template = ScenariosUploadTemplate.new
    send_data(
      csv_template.export,
      type: 'text/csv; charset=utf-8; header=present',
      disposition: 'attachment; filename=scenarios_upload_template.csv'
    )
  end

  def download_time_series
    csv_download = DownloadTimeSeriesValues.new(current_user).call(
      @scenario.time_series_values
    )
    send_data(
      csv_download.export,
      type: 'text/csv; charset=utf-8; header=present',
      disposition: 'attachment; filename=scenario_time_series_data.csv'
    )
  end

  private

  def scenario_params
    params.require(:scenario).permit(
      *Scenario.attribute_symbols_for_strong_params
    )
  end
end
