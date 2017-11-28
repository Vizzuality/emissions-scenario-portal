module Admin
  class HomeController < AdminController
    def index
      @teams = Team.order(:name)
      @models = Model.order(:abbreviation)
      @locations = Location.order(:name)
      @indicators = Indicator.where(parent_id: nil)
      @categories = Category.where(parent_id: nil).order(:name)
    end
  end
end
