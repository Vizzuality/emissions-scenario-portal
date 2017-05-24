class TeamsController < ApplicationController
  before_action :set_team, only: [:edit, :update, :destroy]

  def index
    @teams = Team.all
  end

  def new
    @team = Team.new
    set_available_models
    render :edit
  end

  def edit
    set_available_models
  end

  def create
    @team = Team.new(team_params)

    if @team.save
      redirect_to edit_team_url(@team), notice: 'Team was successfully created.'
    else
      set_available_models
      render :edit
    end
  end

  def update
    if @team.update(team_params)
      redirect_to edit_team_url(@team), notice: 'Team was successfully updated.'
    else
      set_available_models
      render :edit
    end
  end

  def destroy
    @team.destroy
    redirect_to teams_url, notice: 'Team was successfully destroyed.'
  end

  private

  def set_team
    @team = Team.find(params[:id])
  end

  def set_available_models
    @models =
      if @team.present? && @team.persisted?
        Model.where('team_id IS NULL OR team_id = ?', @team.id)
      else
        Model.where('team_id IS NULL')
      end
  end

  def team_params
    params.require(:team).permit(:name, model_ids: [])
  end
end
