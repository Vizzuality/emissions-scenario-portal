class AdminController < ApplicationController
  before_action :ensure_admin

  private

  def ensure_admin
    redirect_to(
      root_path,
      alert: 'You are not authorized to access this page.'
    ) unless current_user.admin?
  end
end
