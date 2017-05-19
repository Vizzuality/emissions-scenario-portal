class IndicatorsController < ApplicationController
  before_action :set_indicator, except: [:index, :new, :create]
  before_action :set_model, :set_nav_links, only: [:index, :show, :edit]

  def index
    @indicators = Indicator.fetch_all(indicator_order_params)
  end

  def new
    @indicator = Indicator.new
    render action: :edit
  end

  def create
    @indicator = Indicator.new(indicator_params)
    if @indicator.save
      redirect_to indicator_url(@indicator)
    else
      render action: :edit
    end
  end

  def edit; end

  def update
    if @indicator.update_attributes(indicator_params)
      redirect_to indicator_url(@indicator)
    else
      render action: :edit
    end
  end

  def show; end

  def destroy
    @indicator = Indicator.find(params[:id])
    @indicator.destroy
    redirect_to indicators_url, notice: 'Indicator successfully destroyed'
  end

  def upload_meta_data
    # TODO: implement
  end

  private

  def set_indicator
    @indicator = Indicator.find(params[:id])
  end

  def set_model
    @model = Model.find(params[:format])
  end

  def indicator_params
    params.require(:indicator).permit(
      *Indicator.attribute_symbols_for_strong_params
    )
  end

  def indicator_order_params
    params.permit(:order_type, :order_direction)
  end
end
