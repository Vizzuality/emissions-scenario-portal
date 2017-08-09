class Api::V1::ModelsController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    models = Model.all
    render json: models
  end

  def show
    model = Model.find_by_id!(params[:id])
    render json: model
  end
end
