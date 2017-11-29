module Admin
  class LocationsController < AdminController
    def index
      @locations = FilterLocations.new(filter_params).call(Location.all)
    end

    def new
      @location = Location.new
      render :edit
    end

    def edit
      @location = Location.find(params[:id])
    end

    def create
      @location = Location.new(location_params)

      if @location.save
        redirect_to edit_admin_location_url(@location),
          notice: 'Country was successfully created.'
      else
        flash[:alert] =
          'We could not create the country. Please check the inputs in red'
        render :edit
      end
    end

    def update
      @location = Location.find(params[:id])
      if @location.update_attributes(location_params)
        redirect_to(
          edit_admin_location_url(@location),
          notice: 'Country was successfully updated.'
        )
      else
        flash[:alert] =
          'We could not update the country. Please check the inputs in red'
        render :edit
      end
    end

    def destroy
      @location = Location.find(params[:id])
      @location.destroy
      redirect_to(
        admin_locations_url,
        notice: 'Country was successfully destroyed.'
      )
    end

    private

    def filter_params
      params.permit(:order_type, :order_direction, :search)
    end

    def location_params
      params.require(:location).permit(:name, :iso_code, :region)
    end
  end
end
