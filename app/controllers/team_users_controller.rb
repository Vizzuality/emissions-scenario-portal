class TeamUsersController < ApplicationController
  before_action :set_team

  def create
    email = user_params[:email].downcase.strip
    @user = User.where('LOWER(email) = ?', email).first
    invite_user(email) and return if @user.nil?
    @user.update_attributes(team: @team)
    flash_message =
      if @user.errors.empty?
        {notice: 'User successfully added to team.'}
      else
        {
          alert: "User could not be added to team. Please ensure this user \
            is not a member of another team."
        }
      end
    redirect_to edit_team_url(@team), flash_message
  end

  def destroy
    @user = User.find(params[:id])
    @user.team_id = nil
    @user.save(validate: false)
    redirect_to(
      edit_team_url(@team),
      notice: 'User successfully removed from team.'
    )
  end

  private

  def invite_user(email)
    user = User.new(email: email, team: @team)
    user.valid?
    flash_message =
      if user.errors[:email].any?
        {
          alert: "User could not be invited. Please ensure email address is \
            valid."
        }
      else
        @user = User.invite!(email: email, team: @team)
        {notice: 'User successfully invited to team.'}
      end
    redirect_to edit_team_url(@team), flash_message
  end

  def set_team
    @team = Team.find(params[:team_id])
  end

  def user_params
    params.require(:user).permit(:email)
  end
end
