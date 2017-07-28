require 'rails_helper'

RSpec.describe TimeSeriesValuesController, type: :controller do
  context 'when user' do
    login_user
    let(:team_model) { FactoryGirl.create(:model, team: @user.team) }
    let(:some_model) { FactoryGirl.create(:model) }

    describe 'POST upload_meta_data' do
      it 'redirects with error when file not given' do
        post :upload, params: {
          model_id: team_model.id
        }
        expect(response).to redirect_to(model_scenarios_url(team_model))
        expect(flash[:alert]).to match(/upload file/)
      end

      it 'redirects with error when file queued' do
        post :upload, params: {
          model_id: team_model.id,
          time_series_values_file: fixture_file_upload(
            'time_series_values-correct.csv', 'text/csv'
          )
        }
        expect(response).to redirect_to(model_scenarios_url(team_model))
        expect(flash[:notice]).to match(/queued/)
      end

      it 'prevents unauthorized access' do
        post :upload, params: {
          model_id: some_model.id,
          time_series_values_file: fixture_file_upload(
            'time_series_values-correct.csv', 'text/csv'
          )
        }
        expect(response).to redirect_to(root_url)
        expect(flash[:alert]).to match(/You are not authorized/)
      end
    end

    describe 'GET upload_template' do
      it 'returns a template file' do
        get :upload_template, params: {
          model_id: team_model.id
        }
        expect(response.content_type).to eq('text/csv')
        expect(response.headers['Content-Disposition']).to eq(
          'attachment; filename=time_series_values_upload_template.csv'
        )
      end
    end
  end
end
