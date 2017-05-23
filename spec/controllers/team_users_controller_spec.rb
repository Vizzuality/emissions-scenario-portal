require 'rails_helper'

RSpec.describe TeamUsersController, type: :controller do
  login_admin

  let(:team) { FactoryGirl.create(:team) }

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
      user = FactoryGirl.create(:user)
      expect {
        delete :destroy, params: {team_id: team.id, id: user.id}
      }.to change(User, :count).by(-1)
    end
  end
end
