require 'rails_helper'

RSpec.describe TeamsController, type: :controller do
  context 'when admin' do
    login_admin

    describe 'GET #index' do
      it 'assigns all teams as @teams' do
        get :index
        expect(assigns(:teams)).to eq([@user.team])
      end
    end

    describe 'GET #new' do
      it 'assigns a new team as @team' do
        get :new
        expect(assigns(:team)).to be_a_new(Team)
      end
      it 'assigns available models' do
        create(:model, team: create(:team))
        unassigned_model = build(:model, team: nil)
        unassigned_model.save(validate: false)
        get :new
        expect(assigns(:models)).to eq([unassigned_model])
      end
    end

    describe 'GET #edit' do
      it 'assigns the requested team as @team' do
        team = create(:team)
        get :edit, params: {id: team.id}
        expect(assigns(:team)).to eq(team)
      end
      it 'assigns available models' do
        team = create(:team)
        create(:model, team: create(:team))
        unassigned_model = build(:model, team: nil)
        unassigned_model.save(validate: false)
        my_model = create(:model, team: team)
        get :edit, params: {id: team.id}
        expect(assigns(:models)).to eq([unassigned_model, my_model])
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
          team = create(:team)
          put :update, params: {id: team.id, team: {name: 'New Name'}}
          team.reload
          expect(team.name).to eq('New Name')
        end

        it 'assigns the requested team as @team' do
          team = create(:team)
          put :update, params: {id: team.id, team: {name: 'New Name'}}
          expect(assigns(:team)).to eq(team)
        end

        it 'redirects to the team' do
          team = create(:team)
          put :update, params: {id: team.id, team: {name: 'New Name'}}
          expect(response).to redirect_to(edit_team_url(team))
        end
      end

      context 'with invalid params' do
        it 'assigns the team as @team' do
          team = create(:team)
          put :update, params: {id: team.id, team: {name: nil}}
          expect(assigns(:team)).to eq(team)
        end

        it 're-renders the edit template' do
          team = create(:team)
          put :update, params: {id: team.id, team: {name: nil}}
          expect(response).to render_template('edit')
        end
      end
    end

    describe 'DELETE #destroy' do
      it 'destroys the requested team' do
        team = create(:team)
        expect {
          delete :destroy, params: {id: team.id}
        }.to change(Team, :count).by(-1)
      end

      it 'redirects to the teams list' do
        team = create(:team)
        delete :destroy, params: {id: team.id}
        expect(response).to redirect_to(teams_url)
      end
    end
  end

  context 'when user' do
    login_user

    describe 'GET #index' do
      it 'assigns user team as @teams' do
        get :index
        expect(assigns(:teams)).to eq([@user.team])
      end
    end

    describe 'GET #new' do
      it 'prevents unauthorized access' do
        get :new
        expect(response).to redirect_to(root_url)
        expect(flash[:alert]).to match(/You are not authorized/)
      end
    end

    describe 'GET #edit' do
      it 'assigns user\'s team as @team' do
        get :edit, params: {id: @user.team.id}
        expect(assigns(:team)).to eq(@user.team)
      end
      it 'prevents unauthorized access' do
        team = create(:team)
        get :edit, params: {id: team.id}
        expect(response).to redirect_to(root_url)
        expect(flash[:alert]).to match(/You are not authorized/)
      end
    end

    describe 'POST #create' do
      it 'prevents unauthorized access' do
        post :create, params: {team: {name: 'New Name'}}
        expect(response).to redirect_to(root_url)
        expect(flash[:alert]).to match(/You are not authorized/)
      end
    end

    describe 'PUT #update' do
      it 'updates user\'s team' do
        put :update, params: {id: @user.team_id, team: {name: 'New Name'}}
        expect(@user.team.reload.name).to eq('New Name')
      end
      it 'prevents unauthorized access' do
        team = create(:team)
        put :update, params: {id: team.id, team: {name: 'New Name'}}
        expect(response).to redirect_to(root_url)
        expect(flash[:alert]).to match(/You are not authorized/)
      end
    end

    describe 'DELETE #destroy' do
      it 'prevents unauthorized access' do
        team = create(:team)
        delete :destroy, params: {id: team.id}
        expect(response).to redirect_to(root_url)
        expect(flash[:alert]).to match(/You are not authorized/)
      end
    end
  end
end
