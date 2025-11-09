# Authentication API Controller
#
# Handles user registration, login, and authentication endpoints.
# Uses JWT (JSON Web Token) for authentication.
#
# @see API.md for endpoint documentation
module Api
  module V1
    class AuthController < ApplicationController
      # Skip CSRF protection for API endpoints (using JWT instead)
      skip_before_action :verify_authenticity_token

      # POST /api/v1/auth/register
      # Register a new user account
      # Default role is 'agent' (can be changed by admin later)
      def register
        Rails.logger.info "=== Register endpoint called ==="
        Rails.logger.info "Params: #{params.inspect}"

        begin
          Rails.logger.info "Parsing user params..."
          user = User.new(user_params)
          user.role = 'agent' # Default role
          Rails.logger.info "User created, attempting save..."

          if user.save
            Rails.logger.info "User saved successfully, generating token..."
            token = JwtService.encode(user_id: user.id)
            Rails.logger.info "Token generated, rendering response..."
            render json: {
              user: user_serializer(user),
              token: token
            }, status: :created
          else
            Rails.logger.warn "User validation failed: #{user.errors.full_messages.join(', ')}"
            render json: { error: { message: user.errors.full_messages.join(', '), code: 'VALIDATION_ERROR' } }, status: :unprocessable_entity
          end
        rescue => e
          error_msg = "#{e.class}: #{e.message}"
          Rails.logger.error "Register error: #{error_msg}"
          Rails.logger.error e.backtrace.first(10).join("\n")

          render json: {
            error: {
              message: 'Internal server error',
              code: 'SERVER_ERROR',
              details: Rails.env.development? ? error_msg : nil
            }
          }, status: :internal_server_error
        end
      end

      # POST /api/v1/auth/login
      # Authenticate user and return JWT token
      # Validates email, password, and active status
      def login
        Rails.logger.info "=== Login endpoint called ==="
        Rails.logger.info "Params: #{params.inspect}"

        begin
          email = params[:email]
          password = params[:password]

          Rails.logger.info "Looking up user by email: #{email}"

          user = User.find_by_email(email)
          Rails.logger.info "User found: #{user.present?}"

          if user.nil?
            Rails.logger.warn "User not found for email: #{email}"
            return render json: { error: { message: 'Invalid email or password', code: 'INVALID_CREDENTIALS' } }, status: :unauthorized
          end

          unless user.active?
            Rails.logger.warn "User is not active: #{email}"
            return render json: { error: { message: 'Invalid email or password', code: 'INVALID_CREDENTIALS' } }, status: :unauthorized
          end

          unless user.authenticate_password(password)
            Rails.logger.warn "Password authentication failed for email: #{email}"
            return render json: { error: { message: 'Invalid email or password', code: 'INVALID_CREDENTIALS' } }, status: :unauthorized
          end

          Rails.logger.info "Authentication successful, recording login..."

          # Try to record login, but don't fail if it doesn't work
          begin
            user.record_login! if user.respond_to?(:record_login!)
          rescue => e
            Rails.logger.warn "Could not record login: #{e.message}"
          end

          Rails.logger.info "Generating token..."
          token = JwtService.encode(user_id: user.id)

          Rails.logger.info "Token generated, rendering response..."

          render json: {
            user: user_serializer(user),
            token: token
          }
        rescue => e
          error_msg = "#{e.class}: #{e.message}"
          Rails.logger.error "Login error: #{error_msg}"
          Rails.logger.error e.backtrace.first(10).join("\n")

          render json: {
            error: {
              message: 'Internal server error',
              code: 'SERVER_ERROR',
              details: Rails.env.development? ? error_msg : nil
            }
          }, status: :internal_server_error
        end
      end

      # GET /api/v1/auth/me
      # Get current authenticated user information
      # Requires valid JWT token in Authorization header
      def me
        authenticate_user!
        render json: { user: user_serializer(current_user) }
      end

      private

      def user_params
        params.require(:user).permit(:email, :password, :password_confirmation, :name, :phone_number)
      end

      def user_serializer(user)
        {
          id: user.id,
          email: user.email,
          name: user.name,
          role: user.role,
          total_points: user.total_points,
          total_items_scanned: user.total_items_scanned
        }
      end
    end
  end
end
