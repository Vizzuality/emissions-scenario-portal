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

  def set_order_params
    @order_params = params.permit(:order_type, :order_direction)
  end

  def after_sign_in_path_for(user)
    if user.admin?
      admin_root_path
    else
      root_path
    end
  end
end
