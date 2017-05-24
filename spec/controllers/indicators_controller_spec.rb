require 'rails_helper'

RSpec.describe IndicatorsController, type: :controller do
  context 'when admin' do
    login_admin
    let(:team_model) { FactoryGirl.create(:model, team: @user.team) }
    let(:some_model) { FactoryGirl.create(:model) }
    let(:team_indicator) {
      i = FactoryGirl.create(:indicator)
      s = FactoryGirl.create(:scenario, model: team_model)
      FactoryGirl.create(:time_series_value, indicator: i, scenario: s)
      i
    }
    let(:some_indicator) {
      i = FactoryGirl.create(:indicator)
      s = FactoryGirl.create(:scenario, model: some_model)
      FactoryGirl.create(:time_series_value, indicator: i, scenario: s)
      i
    }
    pending 'add more specs when per-model indicators in place'
  end

  context 'when user' do
    login_user
    let(:team_model) { FactoryGirl.create(:model, team: @user.team) }
    let(:some_model) { FactoryGirl.create(:model) }
    let(:team_indicator) {
      i = FactoryGirl.create(:indicator)
      s = FactoryGirl.create(:scenario, model: team_model)
      FactoryGirl.create(:time_series_value, indicator: i, scenario: s)
      i
    }
    let(:some_indicator) {
      i = FactoryGirl.create(:indicator)
      s = FactoryGirl.create(:scenario, model: some_model)
      FactoryGirl.create(:time_series_value, indicator: i, scenario: s)
      i
    }

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
        get :edit, params: {id: team_indicator.id}
        expect(response).to render_template(:edit)
      end
    end

    describe 'PUT update' do
      it 'renders edit when validation errors present' do
        put :update, params: {id: team_indicator.id, indicator: {name: nil}}
        expect(response).to render_template(:edit)
      end

      it 'redirects to indicator when successful' do
        put :update, params: {id: team_indicator.id, indicator: {name: 'ABC'}}
        expect(response).to redirect_to(indicator_url(team_indicator))
      end
    end

    describe 'GET show' do
      it 'renders show' do
        get :show, params: {id: team_indicator.id}
        expect(response).to render_template(:show)
      end
    end

    describe 'DELETE destroy' do
      it 'redirects to index' do
        delete :destroy, params: {id: team_indicator.id}
        expect(response).to redirect_to(indicators_url)
      end
    end
  end
end
