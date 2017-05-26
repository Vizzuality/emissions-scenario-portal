require 'rails_helper'

RSpec.describe ModelsController, type: :controller do
  context 'when admin' do
    login_admin
    let!(:team_model) { FactoryGirl.create(:model, team: @user.team) }
    let!(:some_model) { FactoryGirl.create(:model) }

    describe 'GET index' do
      it 'lists all models' do
        get :index
        expect(assigns[:models].count).to eq(2)
      end
    end

    describe 'GET show' do
      it 'renders show' do
        get :show, params: {id: some_model.id}
        expect(response).to render_template(:show)
      end
    end

    describe 'PUT update' do
      it 'renders edit when validation errors present' do
        put :update, params: {id: some_model.id, model: {abbreviation: nil}}
        expect(response).to render_template(:edit)
      end

      it 'redirects to model when successful' do
        put :update, params: {id: some_model.id, model: {abbreviation: 'ABC'}}
        expect(response).to redirect_to(model_url(some_model))
      end
    end
  end

  context 'when user' do
    login_user
    let!(:team_model) { FactoryGirl.create(:model, team: @user.team) }
    let!(:some_model) { FactoryGirl.create(:model) }

    describe 'GET index' do
      it 'lists all models available to the team' do
        get :index
        expect(assigns[:models].count).to eq(1)
      end

      it 'renders index when more than one model available' do
        FactoryGirl.create(:model, team: @user.team)
        get :index
        expect(response).to render_template(:index)
      end

      it 'redirects to model when only one model available' do
        get :index
        expect(response).to redirect_to(model_url(team_model))
      end
    end

    describe 'GET show' do
      it 'renders show' do
        get :show, params: {id: team_model.id}
        expect(response).to render_template(:show)
      end

      it 'prevents unauthorized access' do
        get :show, params: {id: some_model.id}
        expect(response).to redirect_to(root_url)
        expect(flash[:alert]).to match(/You are not authorized/)
      end
    end

    describe 'PUT update' do
      it 'renders edit when validation errors present' do
        put :update, params: {id: team_model.id, model: {abbreviation: nil}}
        expect(response).to render_template(:edit)
      end

      it 'redirects to model when successful' do
        put :update, params: {id: team_model.id, model: {abbreviation: 'ABC'}}
        expect(response).to redirect_to(model_url(team_model))
      end

      it 'prevents unauthorized access' do
        put :update, params: {id: some_model.id, model: {abbreviation: 'ABC'}}
        expect(response).to redirect_to(root_url)
        expect(flash[:alert]).to match(/You are not authorized/)
      end
    end

    it 'filters parameters correctly for update' do
      model_params = {
        abbreviation: 'ABC',
        programming_language: ['', 'ruby', 'perl'],
        time_horizon: ['', 'century']
      }
      expect_any_instance_of(Model).to receive(:update_attributes).
        with(ActionController::Parameters.new(model_params).permit!)
      put :update, params: {
        id: team_model.id,
        model: model_params
      }
    end
  end
end
