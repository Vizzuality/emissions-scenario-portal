class TeamsController < ApplicationController # TODO : AdminController
  before_action :set_team, only: [:edit, :update, :destroy]

  def index
    @teams = Team.all
  end

  def new
    @team = Team.new
    render :edit
  end

  def edit; end

  def create
    @team = Team.new(team_params)

    if @team.save
      redirect_to edit_team_url(@team), notice: 'Team was successfully created.'
    else
      render :edit
    end
  end

  def update
    if @team.update(team_params)
      redirect_to edit_team_url(@team), notice: 'Team was successfully updated.'
    else
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

  def team_params
    params.require(:team).permit(:name, model_ids: [])
  end
end
