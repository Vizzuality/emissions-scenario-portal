class AdminController < ApplicationController
  before_action :ensure_admin

  def home
    @teams = Team.order(:name)
    @models = Model.order(:abbreviation)
    @locations = Location.order(:name)
    @indicators = Indicator.where(parent_id: nil)
  end

  private

  def ensure_admin
    return true if current_user.admin?
    redirect_to '/', alert: 'You are not authorized to access this page.'
  end
end
