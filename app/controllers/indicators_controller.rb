class IndicatorsController < ApplicationController
  load_and_authorize_resource :model
  load_resource except: [:new, :create, :index]
  authorize_resource through: :model

  before_action :set_filter_params, only: [:index]

  def index
    @indicators = Indicator.fetch_all(@filter_params)
    @categories = Indicator.except(:order).
      order(:category).
      distinct.pluck(:category)
  end

  def new
    @indicator = Indicator.new(model: @model)
    render action: :edit
  end

  def create
    @indicator = Indicator.new(indicator_params)
    if @indicator.save
      redirect_to model_indicator_url(@model, @indicator)
    else
      render action: :edit
    end
  end

  def edit; end

  def update
    if @indicator.update_attributes(indicator_params)
      redirect_to model_indicator_url(@model, @indicator)
    else
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
    # TODO: implement
  end

  private

  def indicator_params
    params.require(:indicator).permit(
      *Indicator.attribute_symbols_for_strong_params
    )
  end
end
