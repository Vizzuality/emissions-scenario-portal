class IndicatorsController < ApplicationController
  # TODO: once per-model indicators in place
  # load_and_authorize_resource :model
  # load_and_authorize_resource through: :model, except: [:index]
  load_and_authorize_resource except: [:index]
  authorize_resource only: [:index]

  before_action :set_filter_params, only: [:index]

  def index
    @indicators = Indicator.fetch_all(@filter_params)
    @categories = Indicator.except(:order).
      order(:category).
      distinct.pluck(:category)
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
    @indicator.destroy
    redirect_to indicators_url, notice: 'Indicator successfully destroyed'
  end

  def upload_meta_data
    # TODO: implement
  end

  private

  def indicator_params
    params.require(:indicator).permit(
      *Indicator.attribute_symbols_for_strong_params
    )
  end
end
