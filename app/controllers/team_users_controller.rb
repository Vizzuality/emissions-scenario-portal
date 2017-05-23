class TeamUsersController < ApplicationController
  before_action :set_team

  def create
    email = user_params[:email]
    @user = User.where('LOWER(email) = ?', email.downcase.strip).first
    if @user.nil?
      @user = User.invite!(email: email, team: @team)
    else
      @user.update_attributes(team: @team)
    end

    if @user.errors.empty?
      render json: @user
    else
      render json: {errors: @user.errors}, status: :unprocessable_entity
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    render json: @person, status: :ok
  end

  private

  def set_team
    @team = Team.find(params[:team_id])
  end

  def user_params
    params.require(:user).permit(:email)
  end
end
