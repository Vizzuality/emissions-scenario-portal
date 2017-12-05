class IndicatorsController < ApplicationController
  def index
    @model = Model.find_by(id: params[:model_id])
    @indicators =
      FilterIndicators.
        new(@filter_params).
        call(policy_scope(Indicator))
  end

  def show
    @model = Model.find_by(id: params[:model_id])
    @indicator = Indicator.find(params[:id])
    authorize(@indicator)
    @time_series_values_pivot =
      @indicator.
        time_series_values.
        time_series_values_pivot
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
      redirect_to(
        indicator_path(@indicator),
        notice: 'Indicator was successfully created.'
      )
    else
      flash.now[:alert] =
        'We could not create the indicator. Please check the inputs in red'
      render action: :edit
    end
  end

  def edit
    @indicator = Indicator.find(params[:id])
    authorize(@indicator)
  end

  def update
    @indicator = Indicator.find(params[:id])
    authorize(@indicator)
    if @indicator.update_attributes(indicator_params)
      redirect_to(
        indicator_path(@indicator),
        notice: 'Indicator was successfully updated.'
      )
    else
      flash.now[:alert] =
        'We could not update the indicator. Please check the inputs in red'
      render action: :edit
    end
  end

  def destroy
    @indicator = Indicator.find(params[:id])
    authorize(@indicator)
    @indicator.destroy
    redirect_to(
      indicators_path,
      notice: 'Indicator successfully destroyed'
    )
  end

  private

  def indicator_params
    params.require(:indicator).permit(
      *Indicator.attribute_symbols_for_strong_params
    )
  end

  def filter_params
    params.permit(:search, :order_type, :order_direction, :category)
  end
end
