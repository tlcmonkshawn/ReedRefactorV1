module Api
  module V1
    class BaseController < ApplicationController
      skip_before_action :verify_authenticity_token
      before_action :authenticate_user!

      protected

      def authenticate_user!
        token = request.headers['Authorization']&.gsub(/^Bearer /, '')
        return render_unauthorized unless token

        decoded = JwtService.decode(token)
        return render_unauthorized unless decoded

        @current_user = User.find_by(id: decoded['user_id'])
        return render_unauthorized unless @current_user&.active?
      end

      def current_user
        @current_user
      end

      def render_unauthorized
        render json: { error: { message: 'Unauthorized', code: 'UNAUTHORIZED' } }, status: :unauthorized
      end

      def render_error(message, code: 'ERROR', status: :unprocessable_entity)
        render json: { error: { message: message, code: code } }, status: status
      end

      def render_success(data = nil, status: :ok)
        render json: data, status: status
      end
    end
  end
end

