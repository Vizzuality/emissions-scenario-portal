class ModelsController < ApplicationController
  before_action :set_nav_links, only: [:index, :show, :edit]
  before_action :set_upload_errors, only: [:index]

  def index
    @models = Model.all
    @team = current_user.team
  end

  def new
    @model = Model.new
    @model.team = current_user.team unless current_user.admin?
    render action: :edit
  end

  def create
    @model = Model.new(model_params)
    @model.team = current_user.team unless current_user.admin?
    if @model.save
      redirect_to(
        model_path(@model),
        notice: 'Model was successfully created.'
      )
    else
      flash[:alert] =
        'We could not create the model. Please check the inputs in red'
      render action: :edit
    end
  end

  def edit
    @model = Model.find(params[:id])
  end

  def update
    @model = Model.find(params[:id])
    if @model.update_attributes(model_params)
      redirect_to model_path(@model), notice: 'Model was successfully updated.'
    else
      set_nav_links
      flash[:alert] =
        'We could not update the model. Please check the inputs in red'
      render action: :edit
    end
  end

  def show
    @model = Model.find(params[:id])
    @scenarios = @model.scenarios.limit(5)
    @indicators = Indicator.
      includes(:category, :subcategory).
      order('categories.name, subcategories_indicators.name, indicators.name')
  end

  def destroy
    @model = Model.find(params[:id])
    @model.destroy
    redirect_to models_path, notice: 'Model successfully destroyed.'
  end

  def upload_meta_data
    handle_io_upload(:models_file, models_path) do
      CsvUpload.create(
        user: current_user,
        model: nil,
        service_type: 'UploadModels',
        data: @uploaded_io
      )
    end
  end

  def upload_template
    csv_template = ModelsUploadTemplate.new
    send_data(
      csv_template.export,
      type: 'text/csv; charset=utf-8; header=present',
      disposition: 'attachment; filename=models_upload_template.csv'
    )
  end

  private

  def model_params
    params.require(:model).permit(*Model.attribute_symbols_for_strong_params)
  end

  def redirect_after_upload_path(csv_upload = nil)
    models_path(csv_upload_id: csv_upload.try(:id))
  end
end
