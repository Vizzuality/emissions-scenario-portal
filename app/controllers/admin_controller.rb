class AdminController < ApplicationController
  before_action :ensure_admin

  def home
    @teams = Team.order(:name)
    @models = Model.order(:abbreviation)
    @locations = Location.order(:name)
  end

  private

  def ensure_admin
    render status: :forbidden and return false unless current_user.admin?
  end
end
