require 'rails_helper'

describe Api::V1::LocationsController, type: :controller do
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

      it 'lists all locations' do
        get :index
        parsed_body = JSON.parse(response.body)
        expect(parsed_body.length).to eq(3)
      end

      it 'list only locations with time_series_values data' do
        get :index, params: {time_series: true}
        parsed_body = JSON.parse(response.body)
        expect(parsed_body.length).to eq(2)
      end

      it 'list only locations with time_series for a scenario param' do
        get :index, params: {scenario: scenario_with_location_time_series.id}
        parsed_body = JSON.parse(response.body)
        expect(parsed_body.length).to eq(1)
      end
    end
  end
end
