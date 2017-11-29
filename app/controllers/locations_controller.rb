class LocationsController < ApplicationController
  def index
    @locations =
      FilterLocations.
        new(filter_params).
        call(policy_scope(Location))
  end

  def new
    @location = Location.new
    authorize(@location)
    render :edit
  end

  def edit
    @location = Location.find(params[:id])
    authorize(@location)
  end

  def create
    @location = Location.new(location_params)
    authorize(@location)
    if @location.save
      redirect_to edit_location_path(@location),
                  notice: 'Country was successfully created.'
    else
      flash[:alert] =
        'We could not create the country. Please check the inputs in red'
      render :edit
    end
  end

  def update
    @location = Location.find(params[:id])
    authorize(@location)
    if @location.update_attributes(location_params)
      redirect_to(
        edit_location_path(@location),
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
    authorize(@location)
    @location.destroy
    redirect_to(
      locations_path,
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
