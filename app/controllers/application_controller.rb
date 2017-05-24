class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_user!

  private

  def set_nav_links
    @nav_links = [
      {name: 'Overview', path: model_url(@model), key: 'models'},
      {name: 'Scenarios', path: model_scenarios_url(@model), key: 'scenarios'},
      {name: 'Indicators', path: indicators_url(@model), key: 'indicators'}
    ] if @model.present?
  end

  def set_filter_params
    @filter_params = params.permit(
      :search,
      :order_type,
      :order_direction,
      :category
    )
  end
end
