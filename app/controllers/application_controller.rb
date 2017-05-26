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
end
