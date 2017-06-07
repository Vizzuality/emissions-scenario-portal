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

      it 'renders json' do
        post :upload, params: {
          model_id: team_model.id,
          time_series_values_file: fixture_file_upload(
            'time_series_values-correct.csv', 'text/csv'
          )
        }
        expect(response).to redirect_to(model_scenarios_url(team_model))
        expect(flash[:alert]).to match(/upload again/)
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
  end
end
