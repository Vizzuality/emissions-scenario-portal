require 'rails_helper'

RSpec.describe TeamUsersController, type: :controller do
  let(:team) { FactoryGirl.create(:team) }

  context 'when admin' do
    login_admin

    describe 'POST #create' do
      context 'when new user' do
        it 'creates a new user' do
          expect {
            post :create, params: {
              team_id: team.id, user: {email: 'new_user@hello.com'}
            }
          }.to change(team.users, :count).by(1)
        end
      end
      context 'when existing user' do
        it 'does not create a new user' do
          user = FactoryGirl.create(:user)
          expect {
            post :create, params: {team_id: team.id, user: {email: user.email}}
          }.not_to change(team.users, :count)
        end
      end
    end

    describe 'DELETE #destroy' do
      it 'destroys the user' do
        user = FactoryGirl.create(:user, team: team)
        expect {
          delete :destroy, params: {team_id: team.id, id: user.id}
        }.to change(team.users, :count).by(-1)
      end
    end
  end

  context 'user' do
    login_user

    describe 'POST #create' do
      context 'when new user' do
        it 'creates a new user in user\'s team' do
          expect {
            post :create, params: {
              team_id: @user.team.id, user: {email: 'new_user@hello.com'}
            }
          }.to change(@user.team.users, :count).by(1)
        end
        it 'prevents unauthorized access' do
          post :create, params: {
            team_id: team.id, user: {email: 'new_user@hello.com'}
          }
          expect(response).to redirect_to(root_url)
          expect(flash[:alert]).to match(/You are not authorized/)
        end
      end
      context 'when existing user' do
        it 'does not create a new user' do
          user = FactoryGirl.create(:user)
          expect {
            post :create, params: {
              team_id: @user.team.id, user: {email: user.email}
            }
          }.not_to change(@user.team.users, :count)
        end
      end
    end

    describe 'DELETE #destroy' do
      it 'removes the user from user\'s team' do
        user = FactoryGirl.create(:user, team: @user.team)
        expect {
          delete :destroy, params: {team_id: user.team_id, id: user.id}
        }.to change(@user.team.users, :count).by(-1)
      end
      it 'prevents unauthorized access' do
        user = FactoryGirl.create(:user, team: team)
        delete :destroy, params: {team_id: team.id, id: user.id}
        expect(response).to redirect_to(root_url)
        expect(flash[:alert]).to match(/You are not authorized/)
      end
    end
  end
end
