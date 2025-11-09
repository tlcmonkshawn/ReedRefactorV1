# Be sure to restart your server when you modify this file.
# 
# CORS Configuration for ALL routes:
# - API endpoints (/api/*)
# - Admin pages (/admin/*)
# - Health check (/health)
# - Root page (/)
# - Migration endpoints (/migrations/*)
# - EVERYTHING

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # Allow all origins in production (or specify domains via CORS_ORIGINS env var)
    # Format: "https://reed-refactor-v1-frontend-xxx-uw.a.run.app,http://localhost:8080"
    # For production, include Cloud Run frontend URL
    # For development, specify localhost origins explicitly
    default_origins = Rails.env.production? ? 
      ['https://reed-refactor-v1-frontend-*.run.app', '*'] : 
      ['http://localhost:8080', 'http://localhost:3000', '*']
    origins ENV.fetch('CORS_ORIGINS', default_origins.join(',')).split(',').map(&:strip)

    # Apply CORS to EVERY SINGLE ROUTE - no exceptions
    resource '*',
      headers: [
        'Accept',
        'Accept-Language',
        'Content-Language',
        'Content-Type',
        'Authorization',
        'X-Requested-With',
        'Origin',
        'Access-Control-Request-Method',
        'Access-Control-Request-Headers',
        'X-CSRF-Token',
        'X-Migration-Password',
        'Cache-Control',
        'Pragma',
        'Expires'
      ],
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: false,
      expose: [
        'Authorization',
        'Content-Type',
        'X-Request-Id',
        'X-CSRF-Token',
        'Content-Length'
      ],
      max_age: 86400 # Cache preflight requests for 24 hours
  end
end
