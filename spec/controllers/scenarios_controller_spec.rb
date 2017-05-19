require 'rails_helper'

RSpec.describe ScenariosController, type: :controller do
  let(:model) { FactoryGirl.create(:model) }
  let!(:scenario) { FactoryGirl.create(:scenario, model: model) }

  describe 'GET index' do
    it 'renders index' do
      get :index, params: {model_id: model.id}
      expect(response).to render_template(:index)
    end
  end

  describe 'GET show' do
    it 'renders show' do
      get :show, params: {model_id: model.id, id: scenario.id}
      expect(response).to render_template(:show)
    end
  end

  describe 'GET edit' do
    it 'renders edit' do
      get :edit, params: {model_id: model.id, id: scenario.id}
      expect(response).to render_template(:edit)
    end
  end

  describe 'PUT update' do
    it 'renders edit when validation errors present' do
      put :update, params: {
        model_id: model.id, id: scenario.id, scenario: {name: nil}
      }
      expect(response).to render_template(:edit)
    end

    it 'redirects to indicator when successful' do
      put :update, params: {
        model_id: model.id, id: scenario.id, scenario: {name: 'ABC'}
      }
      expect(response).to redirect_to(model_scenario_url(model, scenario))
    end
  end

  describe 'DELETE destroy' do
    it 'redirects to index' do
      delete :destroy, params: {model_id: model.id, id: scenario.id}
      expect(response).to redirect_to(model_scenarios_url(model))
    end
  end
end
