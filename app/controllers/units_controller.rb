class UnitsController < ApplicationController
  load_and_authorize_resource

  before_action :set_filter_params, only: [:index]

  def index
    @units = Unit
  end

  def new
    @unit = Unit.new
    render :edit
  end

  def edit; end

  def create
    @unit = Unit.new(unit_params)

    if @unit.save
      redirect_to edit_unit_url(@unit), notice: 'Unit was successfully created.'
    else
      flash[:alert] =
        'We could not create the unit. Please check the inputs in red'
      render :edit
    end
  end

  def update
    if @unit.update_attributes(unit_params)
      redirect_to edit_unit_url(@unit), notice: 'Unit was successfully updated.'
    else
      flash[:alert] =
        'We could not update the unit. Please check the inputs in red'
      render :edit
    end
  end

  def destroy
    @unit.destroy
    redirect_to units_url, notice: 'Unit was successfully destroyed.'
  end

  private

  def unit_params
    params.require(:unit).permit(:name)
  end
end
