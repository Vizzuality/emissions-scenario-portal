module Admin
  class TeamUsersController < AdminController
    before_action :set_team
    load_and_authorize_resource :team
    load_and_authorize_resource :user, parent: false, only: [:destroy]
    authorize_resource :user, parent: false, only: [:create]

    def create
      email = user_params[:email].downcase.strip
      @user = User.where('LOWER(email) = ?', email).first
      invite_user(email) and return if @user.nil?
      update_user
    end

    def destroy
      @user.team_id = nil
      @user.save(validate: false)
      redirect_to(
        edit_admin_team_url(@team),
        notice: 'User successfully removed from team.'
      )
    end

    private

    def invite_user(email)
      user = User.new(email: email, name: user_params[:name], team: @team)
      user.valid?
      flash_message =
        if user.errors[:email].any?
          {
            alert: "User could not be invited. Please ensure email address is \
            valid."
          }
        else
          @user = User.invite!(
            email: email, name: user_params[:name], team: @team
          )
          {notice: 'User successfully invited to team.'}
        end
      redirect_to edit_team_url(@team), flash_message
    end

    def update_user
      @user.update_attributes(team: @team, name: user_params[:name])
      flash_message =
        if @user.errors.empty?
          {notice: 'User successfully added to team.'}
        else
          {
            alert: "User could not be added to team. Please ensure this user \
            is not a member of another team."
          }
        end
      redirect_to edit_admin_team_url(@team), flash_message
    end

    def set_team
      @team = Team.find(params[:team_id])
    end

    def user_params
      params.require(:user).permit(:email, :name)
    end
  end
end
