class IndicatorsController < ApplicationController
  before_action :set_nav_links, only: [:index, :show, :edit]
  before_action :set_upload_errors, only: [:index]

  def index
    @indicators =
      FilterIndicators.
        new(@filter_params).
        call(policy_scope(Indicator))
  end

  def new
    @indicator = Indicator.new
    authorize(@indicator)
    render action: :edit
  end

  def create
    @indicator = Indicator.new(indicator_params)
    authorize(@indicator)
    if @indicator.save
      redirect_to model_indicator_path(@model, @indicator),
                  notice: 'Indicator was successfully created.'
    else
      flash[:alert] =
        'We could not create the indicator. Please check the inputs in red'
      render action: :edit
    end
  end

  def edit
    @indicator.find(params[:id])
    authorize(@indicator)
  end

  def update
    @indicator.find(params[:id])
    authorize(@indicator)
    if @indicator.update_attributes(indicator_params)
      redirect_to model_indicator_path(@model, @indicator),
                  notice: 'Indicator was successfully updated.'
    else
      flash[:alert] =
        'We could not update the indicator. Please check the inputs in red'
      render action: :edit
    end
  end

  def show
    @indicator.find(params[:id])
    authorize(@indicator)
    @time_series_values_pivot =
      @indicator.
        time_series_values.
        time_series_values_pivot
  end

  def destroy
    @indicator.find(params[:id])
    authorize(@indicator)
    @indicator.destroy
    redirect_to(
      model_indicators_path(@model),
      notice: 'Indicator successfully destroyed'
    )
  end

  # def upload_meta_data
  #   handle_io_upload(:indicators_file, model_indicators_path(@model)) do
  #     CsvUpload.create(
  #       user: current_user,
  #       model: @model,
  #       service_type: 'UploadIndicators',
  #       data: @uploaded_io
  #     )
  #   end
  # end

  # def upload_template
  #   csv_template = IndicatorsUploadTemplate.new
  #   send_data(
  #     csv_template.export,
  #     type: 'text/csv; charset=utf-8; header=present',
  #     disposition: 'attachment; filename=indicators_upload_template.csv'
  #   )
  # end

  # def download_time_series
  #   @indicator.find(params[:id])
  #   csv_download = DownloadTimeSeriesValues.new(current_user).call(
  #     @indicator.time_series_values
  #   )
  #   send_data(
  #     csv_download.export,
  #     type: 'text/csv; charset=utf-8; header=present',
  #     disposition: 'attachment; filename=indicator_time_series_data.csv'
  #   )
  # end

  private

  def indicator_params
    params.require(:indicator).permit(
      *Indicator.attribute_symbols_for_strong_params
    )
  end

  def redirect_after_upload_path(csv_upload = nil)
    model_indicators_path(@model, csv_upload_id: csv_upload.try(:id))
  end

  def filter_params
    params.permit(:search, :order_type, :order_direction, :category)
  end
end
