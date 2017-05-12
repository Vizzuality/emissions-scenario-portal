class IndicatorsController < ApplicationController
  def index
    @indicators = Indicator.order(:category, :stack_family, :name)
  end
end
