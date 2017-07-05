class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_user!

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.json { head :forbidden }
      format.html { redirect_to root_url, alert: exception.message }
    end
  end

  private

  def set_nav_links
    return unless @model.present?
    @nav_links = [
      {name: 'Overview', path: model_url(@model), key: 'models'},
      {
        name: 'Scenarios',
        path: model_scenarios_url(@model), key: 'scenarios'
      },
      {
        name: 'Indicators',
        path: model_indicators_url(@model), key: 'indicators'
      }
    ]
  end

  def set_filter_params
    @filter_params = params.permit(
      :search,
      :order_type,
      :order_direction,
      :category,
      :type
    )
  end

  def handle_io_upload(file_name, service_class_name, redirect_url)
    @uploaded_io = params[file_name]
    unless @uploaded_io.present?
      redirect_to(
        redirect_url,
        alert: 'Please provide an upload file'
      ) and return
    end
    result = service_class_name.new(current_user, @model).call(@uploaded_io)
    msg = result.stats_message
    redirect_to redirect_url, notice: msg and return if result.no_errors?
    msg += ' Please review the list of errors before trying to upload again.'
    redirect_to redirect_url, alert: msg, flash: {
      upload_errors: result.errors_to_csv
    }
  end
end
