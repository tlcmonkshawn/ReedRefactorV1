# Request logging middleware to help debug 500 errors
# This will log all requests before they reach the controller

# Custom middleware to log all API requests
class RequestLoggingMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)

    # Log API requests
    if request.path.start_with?('/api/')
      Rails.logger.info "=== Incoming API Request ==="
      Rails.logger.info "Method: #{request.request_method}"
      Rails.logger.info "Path: #{request.path}"
      Rails.logger.info "Content-Type: #{request.content_type}"
      Rails.logger.info "Body size: #{request.content_length || 'unknown'}"
    end

    @app.call(env)
  rescue => e
    Rails.logger.error "=== Middleware Error ==="
    Rails.logger.error "Error: #{e.class}: #{e.message}"
    Rails.logger.error "Path: #{request.path rescue 'unknown'}"
    Rails.logger.error e.backtrace.join("\n")
    raise
  end
end

Rails.application.config.middleware.insert_before Rack::Runtime, RequestLoggingMiddleware
