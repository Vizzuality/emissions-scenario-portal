require 'rails_helper'

RSpec.describe IndicatorsController, type: :controller do
  login_user
  let!(:indicator) { FactoryGirl.create(:indicator) }

  describe 'GET index' do
    it 'renders index' do
      get :index
      expect(response).to render_template(:index)
    end
  end

  describe 'GET new' do
    it 'renders edit' do
      get :new
      expect(response).to render_template(:edit)
    end
  end

  describe 'POST create' do
    it 'renders edit when validation errors present' do
      post :create, params: {indicator: {name: nil}}
      expect(response).to render_template(:edit)
    end

    it 'redirects to indicator when successful' do
      post :create, params: {indicator: {name: 'ABC'}}
      expect(response).to redirect_to(indicator_url(assigns(:indicator)))
    end
  end

  describe 'GET edit' do
    it 'renders edit' do
      get :edit, params: {id: indicator.id}
      expect(response).to render_template(:edit)
    end
  end

  describe 'PUT update' do
    it 'renders edit when validation errors present' do
      put :update, params: {id: indicator.id, indicator: {name: nil}}
      expect(response).to render_template(:edit)
    end

    it 'redirects to indicator when successful' do
      put :update, params: {id: indicator.id, indicator: {name: 'ABC'}}
      expect(response).to redirect_to(indicator_url(indicator))
    end
  end

  describe 'GET show' do
    it 'renders show' do
      get :show, params: {id: indicator.id}
      expect(response).to render_template(:show)
    end
  end

  describe 'DELETE destroy' do
    it 'redirects to index' do
      delete :destroy, params: {id: indicator.id}
      expect(response).to redirect_to(indicators_url)
    end
  end
end
