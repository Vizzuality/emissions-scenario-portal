require 'rails_helper'

describe Api::V1::TimeSeriesValuesController, type: :controller do
  context do
    let!(:location) { create(:location) }
    let!(:indicator) { create(:indicator) }
    let!(:scenario) { create(:scenario) }
    let!(:some_time_series_values) {
      create_list(
        :time_series_value,
        10,
        location: location,
        indicator: indicator,
        scenario: scenario
      )
    }

    describe 'GET index' do
      it 'returns a successful 200 response' do
        get :index
        expect(response).to be_success
      end

      it 'lists all time series values' do
        get :index
        parsed_body = JSON.parse(response.body)
        expect(parsed_body.length).to eq(10)
      end
    end
  end
end


