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
      get :show, params: {id: scenario.id}
      expect(response).to render_template(:show)
    end
  end
end
