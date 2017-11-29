class DashboardController < ApplicationController
  before_action :require_admin!

  def index
    @teams = Team.order(:name)
    @models = Model.order(:abbreviation)
    @locations = Location.order(:name)
    @indicators = Indicator.order(:name)
    @categories = Category.where(parent_id: nil).order(:name)
  end
end
