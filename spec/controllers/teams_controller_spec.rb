require 'rails_helper'

RSpec.describe TeamsController, type: :controller do
  login_admin

  describe 'GET #index' do
    it 'assigns all teams as @teams' do
      team = FactoryGirl.create(:team)
      get :index
      expect(assigns(:teams)).to eq([team])
    end
  end

  describe 'GET #new' do
    it 'assigns a new team as @team' do
      get :new
      expect(assigns(:team)).to be_a_new(Team)
    end
  end

  describe 'GET #edit' do
    it 'assigns the requested team as @team' do
      team = FactoryGirl.create(:team)
      get :edit, params: {id: team.id}
      expect(assigns(:team)).to eq(team)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new Team' do
        expect {
          post :create, params: {team: {name: 'New Name'}}
        }.to change(Team, :count).by(1)
      end

      it 'assigns a newly created team as @team' do
        post :create, params: {team: {name: 'New Name'}}
        expect(assigns(:team)).to be_a(Team)
        expect(assigns(:team)).to be_persisted
      end

      it 'redirects to the created team' do
        post :create, params: {team: {name: 'New Name'}}
        expect(response).to redirect_to(edit_team_url(Team.last))
      end
    end

    context 'with invalid params' do
      it 'assigns a newly created but unsaved team as @team' do
        post :create, params: {team: {name: nil}}
        expect(assigns(:team)).to be_a_new(Team)
      end

      it 're-renders the edit template' do
        post :create, params: {team: {name: nil}}
        expect(response).to render_template('edit')
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      it 'updates the requested team' do
        team = FactoryGirl.create(:team)
        put :update, params: {id: team.to_param, team: {name: 'New Name'}}
        team.reload
        expect(team.name).to eq('New Name')
      end

      it 'assigns the requested team as @team' do
        team = FactoryGirl.create(:team)
        put :update, params: {id: team.to_param, team: {name: 'New Name'}}
        expect(assigns(:team)).to eq(team)
      end

      it 'redirects to the team' do
        team = FactoryGirl.create(:team)
        put :update, params: {id: team.to_param, team: {name: 'New Name'}}
        expect(response).to redirect_to(edit_team_url(team))
      end
    end

    context 'with invalid params' do
      it 'assigns the team as @team' do
        team = FactoryGirl.create(:team)
        put :update, params: {id: team.to_param, team: {name: nil}}
        expect(assigns(:team)).to eq(team)
      end

      it 're-renders the edit template' do
        team = FactoryGirl.create(:team)
        put :update, params: {id: team.to_param, team: {name: nil}}
        expect(response).to render_template('edit')
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested team' do
      team = FactoryGirl.create(:team)
      expect {
        delete :destroy, params: {id: team.to_param}
      }.to change(Team, :count).by(-1)
    end

    it 'redirects to the teams list' do
      team = FactoryGirl.create(:team)
      delete :destroy, params: {id: team.to_param}
      expect(response).to redirect_to(teams_url)
    end
  end
end
