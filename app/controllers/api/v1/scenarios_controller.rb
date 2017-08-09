class Api::V1::ScenariosController < ApplicationController
  load_resource :model
  load_resource through: :model

  def index
    render json: @model.scenarios
  end
end
