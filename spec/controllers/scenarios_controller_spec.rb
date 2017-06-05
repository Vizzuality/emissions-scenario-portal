require 'rails_helper'

RSpec.describe ScenariosController, type: :controller do
  context 'when admin' do
    login_admin
    let(:team_model) { FactoryGirl.create(:model, team: @user.team) }
    let(:some_model) { FactoryGirl.create(:model) }
    let!(:team_scenario) { FactoryGirl.create(:scenario, model: team_model) }
    let!(:some_scenario) { FactoryGirl.create(:scenario, model: some_model) }

    describe 'GET index' do
      it 'renders index' do
        get :index, params: {model_id: some_model.id}
        expect(response).to render_template(:index)
      end
    end

    describe 'GET show' do
      it 'renders show' do
        get :show, params: {model_id: some_model.id, id: some_scenario.id}
        expect(response).to render_template(:show)
      end
    end

    describe 'GET edit' do
      it 'renders edit' do
        get :edit, params: {model_id: some_model.id, id: some_scenario.id}
        expect(response).to render_template(:edit)
      end
    end

    describe 'PUT update' do
      it 'redirects to indicator when successful' do
        put :update, params: {
          model_id: some_model.id, id: some_scenario.id, scenario: {name: 'ABC'}
        }
        expect(response).to redirect_to(
          model_scenario_url(some_model, some_scenario)
        )
      end
    end

    describe 'DELETE destroy' do
      it 'redirects to index' do
        delete :destroy, params: {model_id: some_model.id, id: some_scenario.id}
        expect(response).to redirect_to(model_scenarios_url(some_model))
      end
    end
  end

  context 'when user' do
    login_user
    let(:team_model) { FactoryGirl.create(:model, team: @user.team) }
    let(:some_model) { FactoryGirl.create(:model) }
    let!(:team_scenario) { FactoryGirl.create(:scenario, model: team_model) }
    let!(:some_scenario) { FactoryGirl.create(:scenario, model: some_model) }

    describe 'GET index' do
      it 'renders index' do
        get :index, params: {model_id: team_model.id}
        expect(response).to render_template(:index)
      end

      it 'prevents unauthorized access' do
        get :index, params: {model_id: some_model.id}
        expect(response).to redirect_to(root_url)
        expect(flash[:alert]).to match(/You are not authorized/)
      end
    end

    describe 'GET show' do
      it 'renders show' do
        get :show, params: {model_id: team_model.id, id: team_scenario.id}
        expect(response).to render_template(:show)
      end

      it 'prevents unauthorized access' do
        get :show, params: {model_id: some_model.id, id: some_scenario.id}
        expect(response).to redirect_to(root_url)
        expect(flash[:alert]).to match(/You are not authorized/)
      end
    end

    describe 'GET edit' do
      it 'renders edit' do
        get :edit, params: {model_id: team_model.id, id: team_scenario.id}
        expect(response).to render_template(:edit)
      end

      it 'prevents unauthorized access' do
        get :edit, params: {model_id: some_model.id, id: some_scenario.id}
        expect(response).to redirect_to(root_url)
        expect(flash[:alert]).to match(/You are not authorized/)
      end
    end

    describe 'PUT update' do
      it 'renders edit when validation errors present' do
        put :update, params: {
          model_id: team_model.id, id: team_scenario.id, scenario: {name: nil}
        }
        expect(response).to render_template(:edit)
      end

      it 'redirects to indicator when successful' do
        put :update, params: {
          model_id: team_model.id, id: team_scenario.id, scenario: {name: 'ABC'}
        }
        expect(response).to redirect_to(
          model_scenario_url(team_model, team_scenario)
        )
      end

      it 'prevents unauthorized access' do
        put :update, params: {
          model_id: some_model.id, id: some_scenario.id, scenario: {name: 'ABC'}
        }
        expect(response).to redirect_to(root_url)
        expect(flash[:alert]).to match(/You are not authorized/)
      end
    end

    describe 'DELETE destroy' do
      it 'redirects to index' do
        delete :destroy, params: {model_id: team_model.id, id: team_scenario.id}
        expect(response).to redirect_to(model_scenarios_url(team_model))
      end

      it 'prevents unauthorized access' do
        delete :destroy, params: {model_id: some_model.id, id: some_scenario.id}
        expect(response).to redirect_to(root_url)
        expect(flash[:alert]).to match(/You are not authorized/)
      end
    end

    describe 'POST upload_meta_data' do
      it 'redirects with error when file not given' do
        post :upload_meta_data, params: {
          model_id: team_model.id
        }
        expect(response).to redirect_to(model_scenarios_url(team_model))
        expect(flash[:alert]).to match(/upload file/)
      end

      it 'renders json' do
        post :upload_meta_data, params: {
          model_id: team_model.id,
          scenarios_file: fixture_file_upload(
            'scenarios-correct.csv', 'text/csv'
          )
        }
        expect(JSON.parse(response.body)).to include('number_of_rows_failed')
      end

      it 'prevents unauthorized access' do
        post :upload_meta_data, params: {
          model_id: some_model.id,
          scenarios_file: fixture_file_upload(
            'scenarios-correct.csv', 'text/csv'
          )
        }
        expect(response).to redirect_to(root_url)
        expect(flash[:alert]).to match(/You are not authorized/)
      end
    end

    it 'filters parameters correctly for update' do
      scenario_params = {
        name: 'ABC',
        technology_coverage: ['', 'A', 'B'],
        category: ['', 'cat1']
      }
      expect_any_instance_of(Scenario).to receive(:update_attributes).
        with(ActionController::Parameters.new(scenario_params).permit!)
      put :update, params: {
        model_id: team_model.id,
        id: team_scenario.id,
        scenario: scenario_params
      }
    end
  end
end
