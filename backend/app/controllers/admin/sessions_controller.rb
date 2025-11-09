module Admin
  class SessionsController < BaseController
    skip_before_action :authenticate_admin!, only: [:new, :create]

    def new
      # HTTP Basic Auth handles the login form
      # This is just a redirect if already authenticated
      if request.headers['Authorization'].present?
        redirect_to admin_root_path
      end
    end

    def create
      # HTTP Basic Auth handles authentication
      # This action is called after successful auth
      redirect_to admin_root_path
    end

    def destroy
      # HTTP Basic Auth doesn't have a traditional logout
      # Just redirect to root
      redirect_to root_path, notice: 'Logged out successfully.'
    end
  end
end

