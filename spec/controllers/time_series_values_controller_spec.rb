require 'rails_helper'

RSpec.describe TimeSeriesValuesController, type: :controller do
  context 'when user' do
    login_user
    let(:team_model) { create(:model, team: @user.team) }
    let(:some_model) { create(:model) }

    describe 'POST upload_meta_data', upload: :s3 do
      let(:file_name) { 'time_series_values-correct.csv' }
      let(:file_path) { Rails.root.join('spec', 'fixtures', file_name) }
      it 'redirects with error when file not given' do
        post :upload, params: {
          model_id: team_model.id
        }
        expect(response).to redirect_to(model_scenarios_url(team_model))
        expect(flash[:alert]).to match(/upload file/)
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
        post :upload, params: {
          model_id: team_model.id,
          time_series_values_file: fixture_file_upload(
            file_name, 'text/csv'
          )
        }
        expect(response).to redirect_to(
          /#{model_scenarios_url(team_model)}\?csv_upload_id/
        )
        expect(flash[:notice]).to match(/queued/)
      end

      it 'prevents unauthorized access' do
        post :upload, params: {
          model_id: some_model.id,
          time_series_values_file: fixture_file_upload(
            file_name, 'text/csv'
          )
        }
        expect(response).to redirect_to(root_url)
        expect(flash[:alert]).to match(/You are not authorized/)
      end
    end
  end
end
