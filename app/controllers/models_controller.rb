class ModelsController < ApplicationController
  before_action :set_nav_links, only: [:index, :show, :edit]
  before_action :set_upload_errors, only: [:index]

  def index
    @models = policy_scope(Model).all
    @team = current_user.team
  end

  def new
    @model = Model.new
    @model.team = current_user.team unless current_user.admin?
    authorize(@model)
    render action: :edit
  end

  def create
    @model = Model.new(model_params)
    @model.team = current_user.team unless current_user.admin?
    authorize(@model)
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
    authorize(@model)
  end

  def update
    @model = Model.find(params[:id])
    authorize(@model)
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
    authorize(@model)
    @scenarios = @model.scenarios.limit(5)
    @indicators = Indicator.
                    includes(:category, :subcategory).
                    order('categories.name, subcategories_indicators.name, indicators.name')
  end

  def destroy
    @model = Model.find(params[:id])
    authorize(@model)
    @model.destroy
    redirect_to models_path, notice: 'Model successfully destroyed.'
  end

  # POST /models/metadata
  def metadata
    csv_upload = CsvUpload.new(
      user: current_user,
      model: nil,
      service_type: 'UploadModels',
      data: params[:models_file]
    )
    if csv_upload.save
      job = CsvUploadJob.perform_later(csv_upload.id)
      csv_upload.update!(job_id: job.job_id)
      redirect_to(
        models_path(csv_upload_id: csv_upload.id),
        notice: 'File has been queued for processing. Please refresh.'
      )
    else
      redirect_to(
        models_path,
        alert: csv_upload.errors.full_messages.join(', ')
      )
    end
  end

  private

  def model_params
    params.require(:model).permit(*Model.attribute_symbols_for_strong_params)
  end
end
