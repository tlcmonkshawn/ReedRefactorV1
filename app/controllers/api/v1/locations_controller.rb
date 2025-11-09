module Api
  module V1
    class LocationsController < BaseController
      def index
        locations = Location.active.order(:name)
        render json: locations
      end

      def show
        location = Location.find(params[:id])
        render json: location_serializer(location)
      end

      def create
        unless current_user.admin?
          return render_error("Only admins can create locations", code: 'FORBIDDEN', status: :forbidden)
        end

        location = Location.new(location_params)
        
        if location.save
          render json: location_serializer(location), status: :created
        else
          render_error(location.errors.full_messages.join(', '))
        end
      end

      def update
        unless current_user.admin?
          return render_error("Only admins can update locations", code: 'FORBIDDEN', status: :forbidden)
        end

        location = Location.find(params[:id])
        
        if location.update(location_params)
          render json: location_serializer(location)
        else
          render_error(location.errors.full_messages.join(', '))
        end
      end

      def destroy
        unless current_user.admin?
          return render_error("Only admins can delete locations", code: 'FORBIDDEN', status: :forbidden)
        end

        location = Location.find(params[:id])
        location.update(active: false)
        head :no_content
      end

      private

      def location_params
        params.require(:location).permit(:name, :address, :city, :state, :zip_code, :phone_number, :email, :latitude, :longitude, :notes)
      end

      def location_serializer(location)
        {
          id: location.id,
          name: location.name,
          address: location.address,
          city: location.city,
          state: location.state,
          zip_code: location.zip_code,
          full_address: location.full_address,
          phone_number: location.phone_number,
          email: location.email,
          active: location.active
        }
      end
    end
  end
end

