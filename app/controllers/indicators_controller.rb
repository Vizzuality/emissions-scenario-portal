class IndicatorsController < ApplicationController
  load_and_authorize_resource :model
  load_resource except: [:new, :create, :index]
  authorize_resource through: :model

  before_action :set_nav_links, only: [:index, :show, :edit, :fork]
  before_action :set_filter_params, only: [:index]

  def index
    @indicators =
      if current_user.admin?
        Indicator.fetch_all(@filter_params)
      else
        Indicator.for_model(@model).fetch_all(@filter_params)
      end
  end

  def new
    @indicator = Indicator.new(model: @model)
    render action: :edit
  end

  def create
    @indicator = Indicator.new(indicator_params)
    @indicator.model = @model unless current_user.admin?
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

  def show; end

  def destroy
    @indicator.destroy
    redirect_to(
      model_indicators_url(@model),
      notice: 'Indicator successfully destroyed'
    )
  end

  def upload_meta_data
    handle_io_upload(
      :indicators_file,
      UploadIndicators,
      model_indicators_url(@model)
    )
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
end
