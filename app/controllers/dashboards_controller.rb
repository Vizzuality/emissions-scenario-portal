class DashboardsController < ApplicationController
  def show
    @teams = policy_scope(Team).order(:name)
    @models = Model.order(:abbreviation)
    @indicators = Indicator.order(:name)
    @locations = Location.order(:name)
    @categories = Category.where(parent_id: nil).order(:name)
  end
end
