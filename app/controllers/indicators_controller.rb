class IndicatorsController < ApplicationController
  load_and_authorize_resource :model
  load_resource except: [:new, :create, :index]
  authorize_resource through: :model

  before_action :set_nav_links, only: [:index, :show, :edit]
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
    @parent_indicator = @indicator # when forking
    @indicator = Indicator.new(indicator_params)
    @indicator.model = @model unless current_user.admin?
    @indicator.parent = @parent_indicator
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

  def update
    # If this is a researcher trying to update a master indicator
    # fork the indicator
    create and return if !current_user.admin? && @indicator.model.nil?
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
    @uploaded_io = params[:indicators_file]
    unless @uploaded_io.present?
      redirect_to(
        model_indicators_url(@model),
        alert: 'Please provide an upload file'
      ) and return
    end
    result = UploadIndicators.new(current_user, @model).call(@uploaded_io)
    render json: result
  end

  private

  def indicator_params
    params.require(:indicator).permit(
      *Indicator.attribute_symbols_for_strong_params
    )
  end
end
