require 'rails_helper'

RSpec.describe IndicatorsController, type: :controller do
  context 'when admin' do
    login_admin
    let(:user_team) { @user.team }
    let(:some_team) { FactoryGirl.create(:team) }
    let(:team_model) { FactoryGirl.create(:model, team: user_team) }
    let(:some_model) { FactoryGirl.create(:model, team: some_team) }
    let(:team_indicator) { FactoryGirl.create(:indicator, team: user_team) }
    let(:some_indicator) { FactoryGirl.create(:indicator, team: some_team) }
    let(:master_indicator) { FactoryGirl.create(:indicator, team: nil) }

    describe 'GET index' do
      it 'assigns all indicators for own team\'s model' do
        get :index, params: {model_id: team_model.id}
        expect(assigns(:indicators)).to eq(
          [team_indicator, some_indicator, master_indicator]
        )
      end
      it 'assigns all indicators for other team\'s model' do
        get :index, params: {model_id: some_model.id}
        expect(assigns(:indicators)).to eq(
          [team_indicator, some_indicator, master_indicator]
        )
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
      it 'redirects to own team\'s indicator when successful' do
        post :create, params: {
          model_id: team_model.id, indicator: {category: ['ABC']}
        }
        expect(response).to redirect_to(
          model_indicator_url(team_model, assigns(:indicator))
        )
      end

      it 'redirects to other team\'s indicator when successful' do
        post :create, params: {
          model_id: some_model.id, indicator: {category: ['ABC']}
        }
        expect(response).to redirect_to(
          model_indicator_url(some_model, assigns(:indicator))
        )
      end
    end

    describe 'GET edit' do
      it 'renders edit for own team\'s indicator' do
        get :edit, params: {model_id: team_model.id, id: team_indicator.id}
        expect(response).to render_template(:edit)
      end

      it 'renders edit for master indicator' do
        get :edit, params: {model_id: some_model.id, id: master_indicator.id}
        expect(response).to render_template(:edit)
      end

      it 'renders edit for other team\'s indicator' do
        get :edit, params: {model_id: some_model.id, id: some_indicator.id}
        expect(response).to render_template(:edit)
      end
    end

    describe 'PUT update' do
      it 'redirects to own team\'s indicator when successful' do
        put :update, params: {
          model_id: team_model.id,
          id: team_indicator.id,
          indicator: {category: ['ABC']}
        }
        expect(response).to redirect_to(
          model_indicator_url(team_model, team_indicator)
        )
      end

      it 'redirects to other team\'s indicator when successful' do
        put :update, params: {
          model_id: some_model.id,
          id: some_indicator.id,
          indicator: {category: ['ABC']}
        }
        expect(response).to redirect_to(
          model_indicator_url(some_model, some_indicator)
        )
      end

      it ' does not create a model-specific copy of a master indicator' do
        expect {
          put :update, params: {
            model_id: team_model.id,
            id: master_indicator.id,
            indicator: {category: ['ABC']}
          }
        }.not_to change(user_team.indicators, :count)
      end
    end

    describe 'GET show' do
      it 'renders show for own team\'s indicator' do
        get :show, params: {model_id: team_model.id, id: team_indicator.id}
        expect(response).to render_template(:show)
      end

      it 'renders show for master indicator' do
        get :show, params: {model_id: team_model.id, id: master_indicator.id}
        expect(response).to render_template(:show)
      end

      it 'renders show for other team\'s indicator' do
        get :show, params: {model_id: some_model.id, id: some_indicator.id}
        expect(response).to render_template(:show)
      end
    end

    describe 'DELETE destroy' do
      it 'redirects to index for own team\'s indicator' do
        delete :destroy, params: {
          model_id: team_model.id, id: team_indicator.id
        }
        expect(response).to redirect_to(model_indicators_url(team_model))
      end

      it 'redirects to index for master indicator' do
        delete :destroy, params: {
          model_id: team_model.id, id: master_indicator.id
        }
        expect(response).to redirect_to(model_indicators_url(team_model))
      end

      it 'redirects to index for other team\'s indicator' do
        delete :destroy, params: {
          model_id: some_model.id, id: some_indicator.id
        }
        expect(response).to redirect_to(model_indicators_url(some_model))
      end
    end
  end

  context 'when user' do
    login_user
    let(:user_team) { @user.team }
    let(:some_team) { FactoryGirl.create(:team) }
    let!(:team_model) { FactoryGirl.create(:model, team: user_team) }
    let!(:some_model) { FactoryGirl.create(:model, team: some_team) }
    let(:team_indicator) { FactoryGirl.create(:indicator, team: user_team) }
    let(:some_indicator) { FactoryGirl.create(:indicator, team: some_team, unit: 'km') }
    let(:master_indicator) { FactoryGirl.create(:indicator, team: nil) }

    describe 'GET index' do
      it 'renders index' do
        get :index, params: {model_id: team_model.id}
        expect(response).to render_template(:index)
      end
      it 'assigns team and master indicators' do
        get :index, params: {model_id: team_model.id}
        expect(assigns(:indicators)).to eq([team_indicator, master_indicator])
      end
      it 'prevents unauthorized access' do
        get :index, params: {model_id: some_model.id}
        expect(response).to redirect_to(root_url)
        expect(flash[:alert]).to match(/You are not authorized/)
      end
    end

    describe 'GET new' do
      it 'renders edit for own team\'s model' do
        get :new, params: {model_id: team_model.id}
        expect(response).to render_template(:edit)
      end
      it 'prevents unauthorized access' do
        get :new, params: {model_id: some_model.id}
        expect(response).to redirect_to(root_url)
        expect(flash[:alert]).to match(/You are not authorized/)
      end
    end

    describe 'POST create' do
      it 'renders edit when validation errors present' do
        post :create, params: {
          model_id: team_model.id, indicator: {category: [nil]}
        }
        expect(response).to render_template(:edit)
      end

      it 'redirects to indicator when successful' do
        post :create, params: {
          model_id: team_model.id, indicator: {category: ['ABC']}
        }
        expect(response).to redirect_to(
          model_indicator_url(team_model, assigns(:indicator))
        )
      end

      it 'prevents unauthorized access' do
        post :create, params: {
          model_id: some_model.id, indicator: {category: ['ABC']}
        }
        expect(response).to redirect_to(root_url)
        expect(flash[:alert]).to match(/You are not authorized/)
      end

      context 'promoting team indicator to system indicator' do
        before(:each) { some_indicator }
        it 'creates 2 indicators' do
          expect {
            post :create, params: {
              model_id: team_model.id, indicator: {
                parent_id: some_indicator.id, category: ['Unicorns'], unit: ['km']
              }
            }
          }.to change { Indicator.count }.by(2)
        end

        it 'does not create any indicators if validations failed' do
          expect {
            post :create, params: {
              model_id: team_model.id, indicator: {
                parent_id: some_indicator.id, category: ['Unicorns'], unit: ['m']
              }
            }
          }.not_to change { Indicator.count }
        end

        it 'links old team indicator to new system indicator' do
          post :create, params: {
            model_id: team_model.id, indicator: {
              parent_id: some_indicator.id, category: ['Unicorns'], unit: ['km']
            }
          }
          expect(some_indicator.reload.parent).to be_present
        end
      end
    end

    describe 'GET edit' do
      it 'renders edit for own team\'s indicator' do
        get :edit, params: {model_id: team_model.id, id: team_indicator.id}
        expect(response).to render_template(:edit)
      end

      it 'prevents unauthorized access for master indicator' do
        get :edit, params: {model_id: team_model.id, id: master_indicator.id}
        expect(response).to redirect_to(root_url)
        expect(flash[:alert]).to match(/You are not authorized/)
      end

      it 'prevents unauthorized access for other team\'s indicator' do
        get :edit, params: {model_id: team_model.id, id: some_indicator.id}
        expect(response).to redirect_to(root_url)
        expect(flash[:alert]).to match(/You are not authorized/)
      end
    end

    describe 'GET fork' do
      it 'renders edit for master indicator' do
        get :fork, params: {model_id: team_model.id, id: master_indicator.id}
        expect(response).to render_template(:edit)
      end

      it 'renders edit for other team\'s indicator' do
        get :fork, params: {model_id: team_model.id, id: some_indicator.id}
        expect(response).to render_template(:edit)
      end

      it 'redirects to edit to own team\'s indicator' do
        get :fork, params: {model_id: team_model.id, id: team_indicator.id}
        expect(response).to redirect_to(
          edit_model_indicator_url(team_model, team_indicator)
        )
      end
    end

    describe 'PUT update' do
      it 'renders edit when validation errors present' do
        put :update, params: {
          model_id: team_model.id,
          id: team_indicator.id,
          indicator: {category: [nil]}
        }
        expect(response).to render_template(:edit)
      end

      it 'redirects to indicator when successful' do
        put :update, params: {
          model_id: team_model.id,
          id: team_indicator.id,
          indicator: {category: ['ABC']}
        }
        expect(response).to redirect_to(
          model_indicator_url(team_model, team_indicator)
        )
      end

      it 'prevents unauthorized access' do
        put :update, params: {
          model_id: some_model.id,
          id: some_indicator.id,
          indicator: {category: ['ABC']}
        }
        expect(response).to redirect_to(root_url)
        expect(flash[:alert]).to match(/You are not authorized/)
      end
    end

    describe 'GET show' do
      it 'renders show' do
        get :show, params: {model_id: team_model.id, id: team_indicator.id}
        expect(response).to render_template(:show)
      end

      it 'renders show' do
        get :show, params: {model_id: team_model.id, id: master_indicator.id}
        expect(response).to render_template(:show)
      end

      it 'prevents unauthorized access' do
        get :show, params: {model_id: some_model.id, id: some_indicator.id}
        expect(response).to redirect_to(root_url)
        expect(flash[:alert]).to match(/You are not authorized/)
      end
    end

    describe 'DELETE destroy' do
      it 'redirects to index' do
        delete :destroy, params: {
          model_id: team_model.id, id: team_indicator.id
        }
        expect(response).to redirect_to(model_indicators_url(team_model))
      end

      it 'prevents unauthorized access' do
        delete :destroy, params: {
          model_id: team_model.id, id: master_indicator.id
        }
        expect(response).to redirect_to(root_url)
        expect(flash[:alert]).to match(/You are not authorized/)
      end

      it 'prevents unauthorized access' do
        delete :destroy, params: {
          model_id: some_model.id, id: some_indicator.id
        }
        expect(response).to redirect_to(root_url)
        expect(flash[:alert]).to match(/You are not authorized/)
      end
    end

    describe 'POST upload_meta_data' do
      it 'redirects with error when file not given' do
        post :upload_meta_data, params: {
          model_id: team_model.id
        }
        expect(response).to redirect_to(model_indicators_url(team_model))
        expect(flash[:alert]).to match(/upload file/)
      end

      it 'renders json' do
        post :upload_meta_data, params: {
          model_id: team_model.id,
          indicators_file: fixture_file_upload(
            'indicators-correct.csv', 'text/csv'
          )
        }
        expect(response).to redirect_to(model_indicators_url(team_model))
        expect(flash[:alert]).to match(/upload again/)
      end

      it 'prevents unauthorized access' do
        post :upload_meta_data, params: {
          model_id: some_model.id,
          indicators_file: fixture_file_upload(
            'indicators-correct.csv', 'text/csv'
          )
        }
        expect(response).to redirect_to(root_url)
        expect(flash[:alert]).to match(/You are not authorized/)
      end
    end

    describe 'GET download_time_series' do
      it 'returns indicator time series file' do
        FactoryGirl.create(:time_series_value, indicator: team_indicator)

        get :download_time_series, params: {
          model_id: team_model.id, id: team_indicator.id
        }
        expect(response.content_type).to eq('text/csv')
        expect(response.headers['Content-Disposition']).to eq(
          'attachment; filename=indicator_time_series_data.csv'
        )
      end
    end
  end
end
