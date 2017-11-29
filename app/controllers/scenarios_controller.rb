class ScenariosController < ApplicationController
  before_action :set_nav_links, only: [:index, :show, :edit]
  before_action :set_filter_params, only: [:index, :show]
  before_action :set_upload_errors, only: [:index]

  def index
    @model = Model.find(params[:model_id])
    @scenarios = FilterScenarios.new(@filter_params).call(@model.scenarios)
  end

  def edit
    @model = Model.find(params[:model_id])
    @scenario = @model.scenarios.find(params[:id])
  end

  def update
    @model = Model.find(params[:model_id])
    @scenario = @model.scenarios.find(params[:id])
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
    @model = Model.find(params[:model_id])
    @scenario = @model.scenarios.find(params[:id])
    @indicators = FilterIndicators.
      new(@filter_params).
      call(@scenario.indicators)
  end

  def destroy
    @scenario.destroy
    redirect_to(
      model_scenarios_url(@model),
      notice: 'Scenario successfully destroyed.'
    )
  end

  def upload_meta_data
    @model = Model.find(params[:model_id])
    handle_io_upload(:scenarios_file, model_scenarios_url(@model)) do
      CsvUpload.create(
        user: current_user,
        model: @model,
        service_type: 'UploadScenarios',
        data: @uploaded_io
      )
    end
  end

  def upload_template
    @model = Model.find(params[:model_id])
    csv_template = ScenariosUploadTemplate.new
    send_data(
      csv_template.export,
      type: 'text/csv; charset=utf-8; header=present',
      disposition: 'attachment; filename=scenarios_upload_template.csv'
    )
  end

  def download_time_series
    @model = Model.find(params[:model_id])
    @scenario = @model.scenarios.find(params[:id])
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

  def redirect_after_upload_url(csv_upload = nil)
    model_scenarios_url(@model, csv_upload_id: csv_upload.try(:id))
  end
end
