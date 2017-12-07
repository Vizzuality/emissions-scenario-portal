require 'rails_helper'

RSpec.describe IndicatorsController, type: :controller do
  context 'when admin' do
    login_admin
    let(:team_model) { create(:model) }
    let(:some_model) { create(:model) }
    let(:category) { create(:category, name: 'Buildings') }
    let(:subcategory) { create(:category, name: 'Emissions', parent: category) }
    let!(:indicator) { create(:indicator) }

    describe 'GET index' do
      it 'assigns all indicators' do
        get :index, params: {model_id: team_model.id}
        expect(assigns(:indicators)).to match_array([indicator])
      end
    end

    describe 'GET show' do
      it 'renders show for indicator' do
        get :show, params: {model_id: team_model.id, id: indicator.id}
        expect(response).to render_template(:show)
      end
    end

    describe 'DELETE destroy' do
      it 'redirects to index for indicator' do
        delete :destroy, params: {id: indicator.id}
        expect(response).to redirect_to(indicators_url)
      end
    end

    describe 'GET new' do
      it 'renders edit for own team\'s model' do
        get :new, params: {model_id: team_model.id}
        expect(response).to render_template(:edit)
      end
      it 'renders edit for other team\'s model' do
        get :new, params: {model_id: some_model.id}
        expect(response).to render_template(:edit)
      end
    end

    describe 'POST create' do
      it 'redirects to indicator when successful' do
        post(
          :create,
          params: {
            indicator: {
              category_id: category.id,
              subcategory_id: subcategory.id
            }
          }
        )

        expect(response).to redirect_to(indicator_url(assigns(:indicator)))
      end
    end

    describe 'GET edit' do
      it 'renders edit for indicator' do
        get :edit, params: {model_id: some_model.id, id: indicator.id}
        expect(response).to render_template(:edit)
      end
    end

    describe 'PUT update' do
      it 'redirects to indicator' do
        put(
          :update,
          params: {
            id: indicator.id,
            indicator: {
              category_id: category.id
            }
          }
        )
        expect(response).to redirect_to(indicator_url(assigns(:indicator)))
      end
    end
  end

  context 'when user' do
    login_user
    let(:user_team) { @user.team }
    let(:some_team) { create(:team) }
    let(:category) { create(:category, name: 'Buildings') }
    let(:another_category) { create(:category, name: 'Transportation') }
    let!(:team_model) { create(:model, team: user_team) }
    let!(:some_model) { create(:model, team: some_team) }
    let(:indicator) { create(:indicator) }

    describe 'GET index' do
      it 'renders index' do
        get :index, params: {model_id: team_model.id}
        expect(response).to render_template(:index)
      end
      it 'assigns team and indicators' do
        get :index, params: {model_id: team_model.id}
        expect(
          assigns(:indicators)
        ).to match_array([indicator])
      end
    end

    describe 'GET show' do
      it 'renders show' do
        get :show, params: {model_id: team_model.id, id: indicator.id}
        expect(response).to render_template(:show)
      end

      it 'renders show' do
        get :show, params: {model_id: team_model.id, id: indicator.id}
        expect(response).to render_template(:show)
      end
    end

    describe 'GET new' do
      it 'prevents unauthorized access' do
        get :new, params: {model_id: some_model.id}
        expect(response).to redirect_to(root_url)
        expect(flash[:alert]).to match(/You are not authorized/)
      end
    end

    describe 'POST create' do
      it 'prevents unauthorized access' do
        post :create, params: {
          model_id: some_model.id, indicator: {category_id: category.id}
        }
        expect(response).to redirect_to(root_url)
        expect(flash[:alert]).to match(/You are not authorized/)
      end
    end

    describe 'GET edit' do
      it 'prevents unauthorized access for indicator' do
        get :edit, params: {model_id: team_model.id, id: indicator.id}
        expect(response).to redirect_to(root_url)
        expect(flash[:alert]).to match(/You are not authorized/)
      end
    end

    describe 'PUT update' do
      it 'prevents unauthorized access' do
        put :update, params: {
          model_id: some_model.id,
          id: indicator.id,
          indicator: {category_id: category.id}
        }
        expect(response).to redirect_to(root_url)
        expect(flash[:alert]).to match(/You are not authorized/)
      end
    end

    describe 'DELETE destroy' do
      it 'prevents unauthorized access' do
        delete :destroy, params: {
          model_id: team_model.id, id: indicator.id
        }
        expect(response).to redirect_to(root_url)
        expect(flash[:alert]).to match(/You are not authorized/)
      end
    end
  end
end
