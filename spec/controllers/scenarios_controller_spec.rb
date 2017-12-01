require 'rails_helper'

RSpec.describe ScenariosController, type: :controller do
  context 'when admin' do
    login_admin
    let(:team_model) { create(:model, team: @user.team) }
    let(:some_model) { create(:model) }
    let!(:team_scenario) { create(:scenario, model: team_model) }
    let!(:some_scenario) { create(:scenario, model: some_model) }

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

      it 'destroys the scenario' do
        expect {
          delete :destroy, params: {
            model_id: some_model.id, id: some_scenario.id
          }
        }.to change { Scenario.count }.by(-1)
      end

      it 'destroys linked time series data' do
        create(:time_series_value, scenario: some_scenario)
        expect {
          delete :destroy, params: {
            model_id: some_model.id, id: some_scenario.id
          }
        }.to change { TimeSeriesValue.count }.by(-1)
      end
    end
  end

  context 'when user' do
    login_user
    let(:team_model) { create(:model, team: @user.team) }
    let(:some_model) { create(:model) }
    let!(:team_scenario) { create(:scenario, model: team_model) }
    let!(:some_scenario) { create(:scenario, model: some_model) }

    describe 'GET index' do
      it 'renders index' do
        get :index, params: {model_id: team_model.id}
        expect(response).to render_template(:index)
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
