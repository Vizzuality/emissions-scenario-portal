require 'rails_helper'

# rubocop:disable Metrics/LineLength
describe Api::V1::Data::EmissionPathways::LocationsController, type: :controller do
  # rubocop:enable Metrics/LineLength
  context do
    let!(:some_location) { create(:location) }
    let!(:location_with_time_series) {
      loc = create(:location)
      create(:time_series_value, location_id: loc.id)
      loc
    }
    let!(:scenario_with_location_time_series) {
      location_with_time_series = create(:location)
      scenario = create(:scenario)
      create(
        :time_series_value,
        location_id: location_with_time_series.id,
        scenario_id: scenario.id
      )
      scenario
    }

    describe 'GET index' do
      it 'returns a successful 200 response' do
        get :index
        expect(response).to be_success
      end
    end
  end
end
