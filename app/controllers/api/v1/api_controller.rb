module Api
  module V1
    class ApiController < ActionController::API
      before_action :set_access_control_headers

      def set_access_control_headers
        headers['Access-Control-Allow-Origin'] = '*'
        headers['Access-Control-Allow-Methods'] = 'GET'
      end
    end
  end
end
