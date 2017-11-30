class DashboardsController < ApplicationController
  def show
    @teams = policy_scope(Team).order(:name)
    @models = policy_scope(Model).order(:abbreviation)
    @indicators = policy_scope(Indicator).order(:name)
    @locations = policy_scope(Location).order(:name)
    @categories = policy_scope(Category).where(parent_id: nil).order(:name)
  end
end
