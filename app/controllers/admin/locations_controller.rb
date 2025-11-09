module Admin
  class LocationsController < BaseController
    before_action :set_location, only: [:show, :edit, :update, :destroy]

    def index
      @locations = Location.order(:name).page(params[:page])
    end

    def show
    end

    def new
      @location = Location.new
    end

    def create
      @location = Location.new(location_params)
      
      if @location.save
        redirect_to admin_location_path(@location), notice: 'Location was successfully created.'
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @location.update(location_params)
        redirect_to admin_location_path(@location), notice: 'Location was successfully updated.'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @location.update(active: false)
      redirect_to admin_locations_path, notice: 'Location was deactivated.'
    end

    private

    def set_location
      @location = Location.find(params[:id])
    end

    def location_params
      params.require(:location).permit(:name, :address, :city, :state, :zip_code, :phone_number, :email, :latitude, :longitude, :notes, :active)
    end
  end
end

