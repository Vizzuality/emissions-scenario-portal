require 'rails_helper'

RSpec.describe SystemIndicatorsController, type: :controller do
  context 'when admin' do
    login_admin
    let(:team_model) { FactoryGirl.create(:model) }
    let(:some_model) { FactoryGirl.create(:model) }
    let!(:team_indicator) { FactoryGirl.create(:indicator, model: team_model) }
    let!(:some_indicator) { FactoryGirl.create(:indicator, model: some_model) }
    let!(:master_indicator) { FactoryGirl.create(:indicator, model: nil) }

    describe 'GET index' do
      it 'assigns all indicators' do
        get :index
        expect(assigns(:indicators)).to match_array(
          [team_indicator, some_indicator, master_indicator]
        )
      end
    end

    describe 'GET new' do
      it 'renders edit' do
        get :new
        expect(response).to render_template('indicators/edit')
      end
    end

    describe 'POST create' do
      it 'redirects to indicator when successful' do
        post :create, params: {indicator: {category: ['Buildings']}}
        expect(response).to redirect_to(
          indicator_url(assigns(:indicator))
        )
      end
    end

    describe 'GET edit' do
      it 'renders edit for indicator' do
        get :edit, params: {id: team_indicator.id}
        expect(response).to render_template(:edit)
      end
    end

    describe 'PUT update' do
      it 'redirects to indicator when successful' do
        put :update, params: {
          id: team_indicator.id,
          indicator: {category: ['Buildings']}
        }
        expect(response).to redirect_to(
          indicator_url(team_indicator)
        )
      end
    end

    describe 'GET show' do
      it 'renders show for indicator' do
        get :show, params: {id: team_indicator.id}
        expect(response).to render_template(:show)
      end
    end

    describe 'DELETE destroy' do
      it 'redirects to index for indicator' do
        delete :destroy, params: {id: team_indicator.id}
        expect(response).to redirect_to(indicators_url)
      end
    end

    describe 'GET upload_template' do
      it 'returns a template file' do
        get :upload_template
        expect(response.content_type).to eq('text/csv')
        expect(response.headers['Content-Disposition']).to eq(
          'attachment; filename=indicators_upload_template.csv'
        )
      end
    end

    describe 'GET download_time_series' do
      it 'returns indicator time series file' do
        FactoryGirl.create(:time_series_value, indicator: team_indicator)

        get :download_time_series, params: {
          id: team_indicator.id
        }
        expect(response.content_type).to eq('text/csv')
        expect(response.headers['Content-Disposition']).to eq(
          'attachment; filename=indicator_time_series_data.csv'
        )
      end
    end

    describe 'PUT promote' do
      it 'redirects to index' do
        put :promote, params: {id: team_indicator.id}
        expect(response).to redirect_to(indicators_url)
      end
    end
  end

  context 'when user' do
    login_user
    let(:user_team) { @user.team }
    let(:some_team) { FactoryGirl.create(:team) }
    let!(:team_model) { FactoryGirl.create(:model, team: user_team) }
    let!(:some_model) { FactoryGirl.create(:model, team: some_team) }
    let(:team_indicator) { FactoryGirl.create(:indicator, model: team_model) }
    let(:some_indicator) {
      FactoryGirl.create(:indicator, model: some_model, unit: 'km')
    }
    let(:master_indicator) { FactoryGirl.create(:indicator, model: nil) }

    describe 'GET index' do
      it 'assigns available indicators' do
        get :index
        expect(response).to redirect_to(root_url)
        expect(flash[:alert]).to match(/You are not authorized/)
      end
    end

    describe 'GET new' do
      it 'prevents unauthorized access' do
        get :new
        expect(response).to redirect_to(root_url)
        expect(flash[:alert]).to match(/You are not authorized/)
      end
    end

    describe 'POST create' do
      it 'prevents unauthorized access' do
        post :create, params: {
          indicator: {category: ['Buildings']}
        }
        expect(response).to redirect_to(root_url)
        expect(flash[:alert]).to match(/You are not authorized/)
      end
    end

    describe 'GET edit' do
      it 'prevents unauthorized access for other team\'s indicator' do
        get :edit, params: {id: some_indicator.id}
        expect(response).to redirect_to(root_url)
        expect(flash[:alert]).to match(/You are not authorized/)
      end
    end

    describe 'PUT update' do
      it 'prevents unauthorized access' do
        put :update, params: {
          id: some_indicator.id,
          indicator: {category: ['Buildings']}
        }
        expect(response).to redirect_to(root_url)
        expect(flash[:alert]).to match(/You are not authorized/)
      end
    end

    describe 'GET show' do
      it 'prevents unauthorized access' do
        get :show, params: {id: some_indicator.id}
        expect(response).to redirect_to(root_url)
        expect(flash[:alert]).to match(/You are not authorized/)
      end
    end

    describe 'DELETE destroy' do
      it 'prevents unauthorized access' do
        delete :destroy, params: {
          id: master_indicator.id
        }
        expect(response).to redirect_to(root_url)
        expect(flash[:alert]).to match(/You are not authorized/)
      end

      it 'prevents unauthorized access' do
        delete :destroy, params: {
          id: some_indicator.id
        }
        expect(response).to redirect_to(root_url)
        expect(flash[:alert]).to match(/You are not authorized/)
      end
    end

    describe 'POST upload_meta_data' do
      it 'prevents unauthorized access' do
        post :upload_meta_data, params: {
          indicators_file: fixture_file_upload(
            'indicators-correct.csv', 'text/csv'
          )
        }
        expect(response).to redirect_to(root_url)
        expect(flash[:alert]).to match(/You are not authorized/)
      end
    end
  end
end
