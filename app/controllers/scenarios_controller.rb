class ScenariosController < ApplicationController
  before_action :set_model

  def index
    @scenarios = @model.scenarios
  end

  def upload_meta_data
    #  TODO: implement
  end

  private

  def set_model
    @model = Model.find(params[:model_id])
  end
end
