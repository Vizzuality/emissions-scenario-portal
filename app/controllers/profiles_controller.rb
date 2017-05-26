class ProfilesController < ApplicationController
  def edit
    @user = current_user
  end

  def update
    @user = User.find(current_user.id)
    if params[:user][:password].present?
      update_with_password
    else
      update_without_password
    end
  end

  private

  def update_with_password
    if @user.update_with_password(user_params)
      # Sign in the user by passing validation in case their password changed
      bypass_sign_in(@user)
      redirect_to edit_profile_path, notice: 'Profile successfully updated'
    else
      render 'edit'
    end
  end

  def update_without_password
    if @user.update_without_password(user_params.except(:current_password))
      redirect_to edit_profile_path, notice: 'Profile successfully updated'
    else
      render 'edit'
    end
  end

  def user_params
    params.require(:user).permit(
      :email, :name, :password, :password_confirmation, :current_password
    )
  end
end
