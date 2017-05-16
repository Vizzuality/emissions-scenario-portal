class IndicatorsController < ApplicationController
  before_action :set_indicator, except: [:index, :new, :create]

  def index
    @indicators = Indicator.order(:category, :stack_family, :name)
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

  def upload_meta_data
    # TODO: implement
  end

  private

  def set_indicator
    @indicator = Indicator.find(params[:id])
  end

  def indicator_params
    params.require(:indicator).permit(
      *Indicator.attribute_symbols_for_strong_params
    )
  end
end
