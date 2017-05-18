class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :set_nav_links

  private

  def set_nav_links
    @nav_links = [
      {name: 'Overview', path: root_path, key: 'models'},
      {name: 'Scenarios', path: '#', key: 'scenarios'},
      {name: 'Indicators', path: indicators_path, key: 'indicators'}
    ]
  end
end
