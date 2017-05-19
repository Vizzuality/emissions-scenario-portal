class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  private

  def set_nav_links
    @nav_links = [
      {name: 'Overview', path: model_url(@model), key: 'models'},
      {name: 'Scenarios', path: model_scenarios_url(@model), key: 'scenarios'},
      {name: 'Indicators', path: indicators_url(@model), key: 'indicators'}
    ] if @model.present?
  end
end
