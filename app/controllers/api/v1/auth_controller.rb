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
        Rails.logger.info "Request headers: #{request.headers.to_h.select { |k, v| k.start_with?('HTTP_') || k == 'Content-Type' }}"
        STDOUT.flush

        begin
          # Test database connection first
          ActiveRecord::Base.connection.execute("SELECT 1")

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
        rescue ActiveRecord::ConnectionNotEstablished, PG::ConnectionBad, PG::Error => e
          error_msg = "Database connection error: #{e.class}: #{e.message}"
          puts "DATABASE ERROR: #{error_msg}"
          puts e.backtrace.first(5).join("\n")
          Rails.logger.error "Register error - Database: #{error_msg}"
          Rails.logger.error e.backtrace.first(10).join("\n")
          STDOUT.flush

          render json: {
            error: {
              message: 'Database connection error',
              code: 'DATABASE_ERROR',
              details: Rails.env.development? ? error_msg : nil
            }
          }, status: :internal_server_error
        rescue ActionController::ParameterMissing => e
          Rails.logger.error "Register error - missing parameter: #{e.message}"
          Rails.logger.error e.backtrace.first(5).join("\n")
          render json: { error: { message: "Missing required parameter: #{e.message}", code: 'VALIDATION_ERROR' } }, status: :bad_request
        rescue => e
          error_msg = "#{e.class}: #{e.message}"
          puts "ERROR: #{error_msg}"
          puts e.backtrace.first(10).join("\n")
          Rails.logger.error "Register error: #{error_msg}"
          Rails.logger.error "Full backtrace:"
          Rails.logger.error e.backtrace.join("\n")
          STDOUT.flush

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
        # Force log to stdout immediately
        puts "=== LOGIN ENDPOINT CALLED ==="
        puts "Params: #{params.inspect}"
        Rails.logger.info "=== Login endpoint called ==="
        Rails.logger.info "Params: #{params.inspect}"
        STDOUT.flush

        begin
          # Test database connection first
          ActiveRecord::Base.connection.execute("SELECT 1")

          email = params[:email]
          password = params[:password]

          puts "Looking up user by email: #{email}"
          Rails.logger.info "Looking up user by email: #{email}"
          STDOUT.flush

          user = User.find_by(email: email)
          puts "User found: #{user.present?}"
          Rails.logger.info "User found: #{user.present?}"
          STDOUT.flush

          if user.nil?
            puts "User not found"
            Rails.logger.warn "User not found for email: #{email}"
            STDOUT.flush
            return render json: { error: { message: 'Invalid email or password', code: 'INVALID_CREDENTIALS' } }, status: :unauthorized
          end

          unless user.active?
            puts "User is not active"
            Rails.logger.warn "User is not active: #{email}"
            STDOUT.flush
            return render json: { error: { message: 'Invalid email or password', code: 'INVALID_CREDENTIALS' } }, status: :unauthorized
          end

          unless user.authenticate(password)
            puts "Password authentication failed"
            Rails.logger.warn "Password authentication failed for email: #{email}"
            STDOUT.flush
            return render json: { error: { message: 'Invalid email or password', code: 'INVALID_CREDENTIALS' } }, status: :unauthorized
          end

          puts "Authentication successful, recording login..."
          Rails.logger.info "Authentication successful, recording login..."
          STDOUT.flush

          # Try to record login, but don't fail if it doesn't work
          begin
            user.record_login! if user.respond_to?(:record_login!)
          rescue => e
            puts "Warning: Could not record login: #{e.message}"
            Rails.logger.warn "Could not record login: #{e.message}"
            STDOUT.flush
          end

          puts "Generating token..."
          Rails.logger.info "Generating token..."
          STDOUT.flush

          token = JwtService.encode(user_id: user.id)

          puts "Token generated successfully"
          Rails.logger.info "Token generated, rendering response..."
          STDOUT.flush

          render json: {
            user: user_serializer(user),
            token: token
          }
        rescue ActiveRecord::ConnectionNotEstablished, PG::ConnectionBad, PG::Error => e
          error_msg = "Database connection error: #{e.class}: #{e.message}"
          puts "DATABASE ERROR: #{error_msg}"
          puts e.backtrace.first(5).join("\n")
          Rails.logger.error "Login error - Database: #{error_msg}"
          STDOUT.flush

          render json: {
            error: {
              message: 'Database connection error',
              code: 'DATABASE_ERROR',
              details: Rails.env.development? ? error_msg : nil
            }
          }, status: :internal_server_error
        rescue => e
          error_msg = "#{e.class}: #{e.message}"
          puts "ERROR: #{error_msg}"
          puts e.backtrace.first(10).join("\n")
          Rails.logger.error "Login error: #{error_msg}"
          Rails.logger.error "Full backtrace:"
          Rails.logger.error e.backtrace.join("\n")
          STDOUT.flush

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
