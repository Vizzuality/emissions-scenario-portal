require 'rails_helper'

RSpec.describe ProfilesController, type: :controller do
  login_user

  describe 'GET #edit' do
    it 'assigns current_user as @user' do
      get :edit
      expect(assigns(:user)).to eq(@user)
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      it 'updates current_user without password change' do
        put :update, params: {user: {name: 'Super Joe'}}
        @user.reload
        expect(@user.name).to eq('Super Joe')
      end
      it 'updates current_user with password change' do
        put :update, params: {
          user: {
            name: 'Super Joe',
            password: '5up3r-j0e',
            password_confirmation: '5up3r-j0e',
            current_password: @user.password
          }
        }
        @user.reload
        expect(@user.name).to eq('Super Joe')
      end
    end

    context 'with invalid params' do
      it 're-renders the edit template without password change' do
        put :update, params: {user: {email: nil}}
        expect(response).to render_template('edit')
      end
      it 're-renders the edit template without password change' do
        put :update, params: {
          user: {
            name: 'Super Joe',
            password: '5up3r-j0e',
            password_confirmation: 'sup3r-j0e',
            current_password: 'bazinga'
          }
        }
        expect(response).to render_template('edit')
      end
    end
  end
end
