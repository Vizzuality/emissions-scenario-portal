require 'rails_helper'

RSpec.describe TemplatesController, type: :controller do
  context "when user" do
    login_user

    describe '#show' do
      it 'returns models template file' do
        get :show, params: {id: "models"}
        expect(response.content_type).to eq('text/csv')
        expect(response.headers['Content-Disposition']).
          to eq('attachment; filename=models_upload_template.csv')
      end

      it 'returns indicators template file' do
        get :show, params: {id: "indicators"}
        expect(response.content_type).to eq('text/csv')
        expect(response.headers['Content-Disposition']).to eq(
          'attachment; filename=indicators_upload_template.csv'
        )
      end

      it 'returns a time series values template file' do
        get :show, params: {id: "time_series_values"}
        expect(response.content_type).to eq('text/csv')
        expect(response.headers['Content-Disposition']).to eq(
          'attachment; filename=time_series_values_upload_template.csv'
        )
      end

      it 'returns scenarios template file' do
        get :show, params: {id: "scenarios"}
        expect(response.content_type).to eq('text/csv')
        expect(response.headers['Content-Disposition']).to eq(
          'attachment; filename=scenarios_upload_template.csv'
        )
      end

      it 'returns notes template file' do
        model = create(:model)
        create(:indicator)
        get :show, params: {id: "notes", model_id: model.id}
        expect(response.content_type).to eq('text/csv')
        expect(response.headers['Content-Disposition']).to eq(
          'attachment; filename=notes_upload_template.csv'
        )
      end
    end
  end
end
