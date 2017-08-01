class SystemIndicatorsController < AdminController
  load_resource :indicator, parent: false, except: [:new, :create, :index]
  authorize_resource :indicator
  before_action :set_filter_params, only: [:index, :show]

  def index
    @indicators = Indicator.system_indicators_with_variations.
      fetch_all(@filter_params)
    render template: 'indicators/index'
  end

  def new
    @indicator = Indicator.new(model: nil, parent: nil)
    render template: 'indicators/edit'
  end

  def create
    @indicator = Indicator.new(indicator_params)
    if @indicator.save
      redirect_to indicator_url(@indicator),
                  notice: 'Indicator was successfully created.'
    else
      flash[:alert] =
        'We could not create the indicator. Please check the inputs in red'
      render action: :edit
    end
  end

  def edit
    render template: 'indicators/edit'
  end

  def update
    if @indicator.update_attributes(indicator_params)
      redirect_to indicator_url(@indicator),
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
    render template: 'indicators/show'
  end

  def destroy
    @indicator.destroy
    redirect_to(
      indicators_url,
      notice: 'Indicator successfully destroyed'
    )
  end

  def upload_meta_data
    handle_io_upload(:indicators_file, indicators_url) do
      UploadIndicators.new(current_user, nil).
        call(@uploaded_io)
    end and return
    index
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

  def promote
    @indicator.promote_to_system_indicator
    redirect_to(
      indicators_url,
      notice: 'Indicator successfully promoted'
    )
  end

  private

  def indicator_params
    params.require(:indicator).permit(
      *Indicator.attribute_symbols_for_strong_params
    )
  end
end
