class Api::V1::ScenariosController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    model = Model.find_by_id!(params[:model_id])
    render json: model.scenarios.order(:updated_at)
  end
end
