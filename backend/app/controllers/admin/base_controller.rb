module Admin
  class BaseController < ApplicationController
    # Skip CSRF protection for admin pages (using HTTP Basic Auth instead)
    skip_before_action :verify_authenticity_token
    
    before_action :authenticate_admin!

    private

    def authenticate_admin!
      authenticate_or_request_with_http_basic do |username, password|
        password == ENV['ADMIN_PASSWORD'] || password == 'admin' # Fallback for development
      end
    end
  end
end

