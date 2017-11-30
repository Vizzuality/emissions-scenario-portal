require 'rails_helper'

RSpec.describe ModelsController, type: :controller do
  context 'when admin' do
    login_admin
    let!(:team_model) { create(:model, team: @user.team) }
    let!(:some_model) { create(:model) }

    describe 'GET index' do
      it 'lists all models' do
        get :index
        expect(assigns[:models].count).to eq(2)
      end
    end

    describe 'GET new' do
      it 'renders edit' do
        get :new
        expect(response).to render_template(:edit)
      end
    end

    describe 'POST create' do
      it 'redirects to models when successful' do
        post :create, params: {
          model: {abbreviation: 'ABC', full_name: 'ABC model'}
        }
        expect(response).to redirect_to(model_url(assigns(:model)))
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

    describe 'DELETE destroy' do
      it 'redirects to index' do
        delete :destroy, params: {id: some_model.id}
        expect(response).to redirect_to(models_url)
      end

      it 'destroys the model' do
        expect {
          delete :destroy, params: {id: some_model.id}
        }.to change { Model.count }.by(-1)
      end

      it 'destroys linked scenarios' do
        create(:scenario, model: some_model)
        expect {
          delete :destroy, params: {id: some_model.id}
        }.to change { Scenario.count }.by(-1)
      end
    end
  end

  context 'when user' do
    login_user
    let!(:team_model) { create(:model, team: @user.team) }
    let!(:some_model) { create(:model) }

    describe 'GET index' do
      it 'lists all models available to the team' do
        get :index
        expect(assigns[:models].count).to eq(1)
      end

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
        post :create, params: {
          model: {abbreviation: 'ABC', full_name: nil}
        }
        expect(response).to render_template(:edit)
      end
      it 'redirects to models when successful' do
        post :create, params: {
          model: {abbreviation: 'ABC', full_name: 'ABC Model'}
        }
        expect(response).to redirect_to(model_url(assigns(:model)))
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

    describe 'DELETE destroy' do
      it 'redirects to index' do
        delete :destroy, params: {id: team_model.id}
        expect(response).to redirect_to(models_url)
      end

      it 'prevents unauthorized access' do
        delete :destroy, params: {id: some_model.id}
        expect(response).to redirect_to(root_url)
        expect(flash[:alert]).to match(/You are not authorized/)
      end
    end

    describe 'POST metadata', upload: :s3 do
      let(:file_name) { 'models-invalid_column.csv' }
      let(:file_path) { Rails.root.join('spec', 'fixtures', file_name) }
      it 'redirects with error when file not given' do
        post :metadata
        expect(response).to redirect_to(models_url)
        expect(flash[:alert]).to match(/Data can't be blank/)
      end

      it 'redirects with notice when file queued' do
        attachment_adapter = instance_double(
          'Paperclip::AttachmentAdapter',
          path: file_path,
          assignment?: true,
          original_filename: file_name,
          content_type: 'text/csv',
          size: File.size?(file_path)
        )
        allow_any_instance_of(
          Paperclip::AdapterRegistry
        ).to receive(:for).and_return(attachment_adapter)
        post :metadata, params: {
          models_file: fixture_file_upload(
            file_name, 'text/csv'
          )
        }
        expect(response).to redirect_to(/#{models_url}\?csv_upload_id/)
        expect(flash[:notice]).to match(/queued/)
      end
    end

    describe 'GET template' do
      it 'returns a template file' do
        get :template
        expect(response.content_type).to eq('text/csv')
        expect(response.headers['Content-Disposition']).to eq(
          'attachment; filename=models_upload_template.csv'
        )
      end
    end

    it 'filters parameters correctly for update' do
      model_params = {
        abbreviation: 'ABC',
        anticipation: ['', 'perfect', 'static'],
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
