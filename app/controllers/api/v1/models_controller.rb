class Api::V1::ModelsController < ApplicationController
  load_resource

  def index
    render json: @models
  end

  def show
    render json: @model
  end
end
