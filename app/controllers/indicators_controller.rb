require 'indicators_upload_template'

class IndicatorsController < ApplicationController
  load_and_authorize_resource :model
  load_resource except: [:new, :create, :index]
  authorize_resource through: :model

  before_action :set_nav_links, only: [:index, :show, :edit, :fork]
  before_action :set_filter_params, only: [:index, :show]
  before_action :set_upload_errors, only: [:index]

  def index
    @indicators = FilterIndicators.
      new(@filter_params).
      call(
        Indicator.
          system_and_team.exclude_with_variations_in_model(@model).
          or(Indicator.model_variations(@model)).
          includes(:time_series_values)
      )
  end

  def new
    @indicator = Indicator.new(model: @model)
    render action: :edit
  end

  def create
    @indicator = Indicator.new(indicator_params)
    unless current_user.admin? && @indicator.parent_id.nil?
      @indicator.model = @model
    end
    if @indicator.save
      redirect_to model_indicator_url(@model, @indicator),
                  notice: 'Indicator was successfully created.'
    else
      flash[:alert] =
        'We could not create the indicator. Please check the inputs in red'
      render action: :edit
    end
  end

  def edit; end

  def fork
    if current_user.team.model_ids.include?(@indicator.model_id)
      redirect_to edit_model_indicator_url(@model, @indicator) and return
    end
    original_indicator = @indicator
    @indicator = original_indicator.dup
    @indicator.parent = original_indicator
    render :edit
  end

  def update
    if @indicator.update_attributes(indicator_params)
      redirect_to model_indicator_url(@model, @indicator),
                  notice: 'Indicator was successfully updated.'
    else
      flash[:alert] =
        'We could not update the indicator. Please check the inputs in red'
      render action: :edit
    end
  end

  def show
    @time_series_values_pivot = TimeSeriesValue.fetch_all(
      @indicator.time_series_values, @filter_params
    )
  end

  def destroy
    @indicator.destroy
    redirect_to(
      model_indicators_url(@model),
      notice: 'Indicator successfully destroyed'
    )
  end

  def upload_meta_data
    handle_io_upload(:indicators_file, model_indicators_url(@model)) do
      CsvUpload.create(
        user: current_user,
        model: @model,
        service_type: 'UploadIndicators',
        data: @uploaded_io
      )
    end
  end

  def upload_template
    csv_template = IndicatorsUploadTemplate.new
    send_data(
      csv_template.export,
      type: 'text/csv; charset=utf-8; header=present',
      disposition: 'attachment; filename=indicators_upload_template.csv'
    )
  end

  def download_time_series
    csv_download = DownloadTimeSeriesValues.new(current_user).call(
      @indicator.time_series_values
    )
    send_data(
      csv_download.export,
      type: 'text/csv; charset=utf-8; header=present',
      disposition: 'attachment; filename=indicator_time_series_data.csv'
    )
  end

  private

  def indicator_params
    params.require(:indicator).permit(
      *Indicator.attribute_symbols_for_strong_params
    )
  end

  def redirect_after_upload_url(csv_upload = nil)
    model_indicators_url(@model, csv_upload_id: csv_upload.try(:id))
  end
end
