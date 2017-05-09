require 'rails_helper'

RSpec.describe ModelsController, type: :controller do

  let(:team){ FactoryGirl.create(:team) }
  let!(:model) { FactoryGirl.create(:model, team: team) }

  describe 'GET index' do
    it 'renders index when more than one model available' do
      FactoryGirl.create(:model, team: team)
      get :index
      expect(response).to render_template(:index)
    end

    it 'redirects to model when only one model available' do
      get :index
      expect(response).to redirect_to(model_url(model))
    end
  end

  describe 'GET show' do
    it 'renders show' do
      get :show, params: {id: model.id}
      expect(response).to render_template(:show)
    end
  end

  describe 'PUT update' do
    it 'renders edit when validation errors present' do
      put :update, params: {id: model.id, model: {abbreviation: nil}}
      expect(response).to render_template(:edit)
    end

    it 'redirects to model when successful' do
      put :update, params: {id: model.id, model: {abbreviation: 'ABC'}}
      expect(response).to redirect_to(model_url(model))
    end
  end

end
