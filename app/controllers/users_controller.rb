class UsersController < ApplicationController
  def create
    @team = Team.find(params[:team_id])
    authorize(@team, :update?)
    email = user_params[:email].downcase.strip
    @user = User.where('LOWER(email) = ?', email).first

    if @user.nil?
      invite_user(email)
    else
      update_user
    end
  end

  def invite
    team = Team.find(params[:team_id])
    user = team.users.find(params[:id])
    user.deliver_invitation
    redirect_to(
      edit_team_path(team),
      notice: 'Invitation has been resent.'
    )
  end

  def destroy
    team = Team.find(params[:team_id])
    authorize(team, :update?)
    user = team.users.find(params[:id])
    user.team_id = nil
    user.save(validate: false)
    redirect_to(
      edit_team_path(team),
      notice: 'User successfully removed from team.'
    )
  end

  private

  def invite_user(email)
    user = User.new(email: email, name: user_params[:name], team: @team)
    user.validate
    if user.errors[:email].blank?
      @user = User.invite!(
        email: email, name: user_params[:name], team: @team
      )
      redirect_to(
        edit_team_path(@team),
        notice: 'User successfully invited to team.'
      )
    else
      redirect_to(
        edit_team_path(@team),
        alert: "User could not be invited. Please ensure email address is \
          valid."
      )
    end
  end

  def update_user
    if @user.update(team: @team, name: user_params[:name])
      redirect_to(
        edit_team_path(@team),
        notice: 'User successfully invited to team.'
      )
    else
      redirect_to(
        edit_team_path(@team),
        alert: "User could not be added to team. Please ensure this user \
            is not a member of another team."
      )
    end
  end

  def user_params
    params.require(:user).permit(:email, :name)
  end
end
