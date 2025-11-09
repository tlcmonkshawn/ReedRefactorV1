module Api
  module V1
    # Config controller - GET is public, PUT requires authentication
    class ConfigController < ApplicationController
      skip_before_action :verify_authenticity_token

      # GET /api/v1/config
      # Get system configuration (public info only - no auth required)
      def show
        render json: {
          api_version: 'v1',
          features: {
            authentication: true,
            booties: true,
            locations: true,
            gamification: true,
            gemini_live: ENV['GEMINI_API_KEY'].present?,
            image_processing: ENV['GOOGLE_CLOUD_PROJECT_ID'].present?,
          },
          limits: {
            max_image_size: 10.megabytes,
            max_booties_per_user: nil, # No limit
          }
        }
      end

      # PUT /api/v1/config
      # Update system configuration (admin only - requires JWT auth)
      def update
        # Require authentication for updates
        token = request.headers['Authorization']&.gsub(/^Bearer /, '')
        unless token
          return render json: { error: { message: 'Unauthorized', code: 'UNAUTHORIZED' } }, status: :unauthorized
        end

        decoded = JwtService.decode(token)
        unless decoded
          return render json: { error: { message: 'Invalid token', code: 'UNAUTHORIZED' } }, status: :unauthorized
        end

        user = User.find_by(id: decoded['user_id'])
        unless user&.admin?
          return render json: { error: { message: 'Forbidden - Admin access required', code: 'FORBIDDEN' } }, status: :forbidden
        end

        # For now, config is read-only
        # In the future, this could update system settings
        render json: { error: { message: 'Configuration updates not yet implemented', code: 'NOT_IMPLEMENTED' } }, status: :not_implemented
      end
    end
  end
end
