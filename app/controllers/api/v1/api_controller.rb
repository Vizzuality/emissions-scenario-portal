module Api
  module V1
    class ApiController < ActionController::API
      
      rescue_from ActiveRecord::RecordNotFound, with: :resource_not_found

      def resource_not_found
        render json: {
          code: 404,
          status: 'resource not found'
        }, status: :not_found
        
      before_action :set_access_control_headers

      def set_access_control_headers
        headers['Access-Control-Allow-Origin'] = '*'
        headers['Access-Control-Allow-Methods'] = 'GET'
      end
    end
  end
end
