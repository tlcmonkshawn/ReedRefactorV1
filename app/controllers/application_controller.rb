class ApplicationController < ActionController::Base
  # CSRF Protection:
  # - API endpoints (/api/*) - Skip CSRF (use JWT auth instead)
  # - Admin pages (/admin/*) - Skip CSRF (use HTTP Basic Auth instead) - handled in Admin::BaseController
  # - Health check (/health) - Skip CSRF - handled in HealthController
  # - Root page (/) - Skip CSRF - handled in RootController
  # - Migrations (/migrations/*) - Skip CSRF - handled in MigrationsController
  # All other routes will use CSRF protection
  protect_from_forgery with: :exception, unless: -> { request.path.start_with?('/api/') }

  # Log all requests to API endpoints
  before_action :log_request, if: -> { request.path.start_with?('/api/') }

  # Catch and log any errors that occur before controller actions
  rescue_from StandardError, with: :handle_error

  private

  def log_request
    Rails.logger.info "=== ApplicationController: #{request.method} #{request.path} ==="
    Rails.logger.info "Params: #{params.except(:controller, :action).inspect}"
  end

  def handle_error(exception)
    Rails.logger.error "=== ApplicationController Error ==="
    Rails.logger.error "Error: #{exception.class}: #{exception.message}"
    Rails.logger.error "Path: #{request.path}"
    Rails.logger.error "Full backtrace:"
    Rails.logger.error exception.backtrace.join("\n")

    # For API requests, return JSON error
    if request.path.start_with?('/api/')
      render json: {
        error: {
          message: 'Internal server error',
          code: 'SERVER_ERROR',
          details: Rails.env.development? ? exception.message : nil
        }
      }, status: :internal_server_error
    else
      # For HTML pages (admin), show error message
      render plain: "Internal Server Error: #{exception.message}", status: :internal_server_error
    end
  end
end
