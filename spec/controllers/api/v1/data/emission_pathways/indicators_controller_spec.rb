require 'rails_helper'

# rubocop:disable Metrics/LineLength
describe Api::V1::Data::EmissionPathways::IndicatorsController, type: :controller do
  # rubocop:enable Metrics/LineLength
  context do
    let!(:some_indicator) { create(:indicator) }
    let!(:indicator_with_time_series) {
      ind = create(:indicator)
      create(:time_series_value, indicator_id: ind.id)
      ind
    }

    describe 'GET index' do
      it 'returns a successful 200 response' do
        get :index
        expect(response).to be_success
      end
    end
  end
end
