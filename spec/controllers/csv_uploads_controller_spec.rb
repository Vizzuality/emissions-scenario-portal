require 'rails_helper'

RSpec.describe CsvUploadsController, type: :controller do
  context 'when user' do
    login_user

    let(:user_team) { @user.team }
    let(:team_model) { create(:model, team: user_team) }

    describe 'POST create', upload: :s3 do
      it 'redirects with error when file not given' do
        post(
          :create,
          params: {
            return_path: models_path,
            csv_upload: {service_type: 'ModelsUpload'}
          }
        )
        expect(response).to redirect_to(models_url)
        expect(flash[:alert]).to match(/Data can't be blank/)
      end

      it 'redirects with notice when models file queued' do
        file_name = 'models-invalid_column.csv'
        file_path = Rails.root.join('spec', 'fixtures', file_name)

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

        post(
          :create,
          params: {
            return_path: models_path,
            csv_upload: {
              data: fixture_file_upload(file_name, 'text/csv'),
              service_type: 'UploadModels'
            }
          }
        )

        expect(response).to redirect_to(/#{models_url}\?csv_upload_id/)
        expect(flash[:notice]).to match(/queued/)
      end

      it 'redirects with notice when indicators file queued' do
        file_name = 'indicators-missing_column.csv'
        file_path = Rails.root.join('spec', 'fixtures', file_name)

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

        post(
          :create,
          params: {
            return_path: model_indicators_path(team_model),
            csv_upload: {
              model_id: team_model.id,
              service_type: 'UploadIndicators',
              data: fixture_file_upload(file_name, 'text/csv')
            }
          }
        )

        expect(response).
          to redirect_to(/#{model_indicators_url(team_model)}\?csv_upload_id/)
        expect(flash[:notice]).to match(/queued/)
      end


      it 'redirects with notice when scenario file queued' do
        file_name = 'scenarios-correct.csv'
        file_path = Rails.root.join('spec', 'fixtures', file_name)

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

        post(
          :create,
          params: {
            return_path: model_scenarios_path(team_model),
            csv_upload: {
              data: fixture_file_upload(file_name, 'text/csv'),
              model_id: team_model.id,
              service_type: 'UploadScenarios'
            }
          }
        )

        expect(response).to redirect_to(
          /#{model_scenarios_url(team_model)}\?csv_upload_id/
        )
        expect(flash[:notice]).to match(/queued/)
      end

      it 'redirects with notice when time series values file queued' do
        file_name = 'time_series_values-correct.csv'
        file_path = Rails.root.join('spec', 'fixtures', file_name)

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

        post(
          :create,
          params: {
            return_path: model_scenarios_path(team_model),
            csv_upload: {
              data: fixture_file_upload(file_name, 'text/csv'),
              model_id: team_model.id,
              service_type: 'UploadTimeSeriesValues'
            }
          }
        )

        expect(response).to redirect_to(
          /#{model_scenarios_url(team_model)}\?csv_upload_id/
        )
        expect(flash[:notice]).to match(/queued/)
      end
    end
  end
end
