class AdminController < ApplicationController
  before_action :ensure_admin

  private

  def ensure_admin
    return true if current_user.admin?
    redirect_to '/', alert: 'You are not authorized to access this page.'
  end
end
