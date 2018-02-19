require 'rails_helper'

describe Api::V1::IndicatorsController, type: :controller do
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

      it 'lists all indicators' do
        get :index
        parsed_body = JSON.parse(response.body)
        expect(parsed_body.length).to eq(2)
      end

      it 'list all stackable indicators' do
        create(:indicator, stackable: true)
        get :index, params: {stackable: true}

        parsed_body = JSON.parse(response.body)
        expect(parsed_body.length).to eq(1)
      end

      it 'list all stackable indicators' do
        get :index, params: {stackable: false}

        parsed_body = JSON.parse(response.body)
        expect(parsed_body.length).to eq(2)
      end

      it 'list all indicators with time_series_values associated' do
        get :index, params: {time_series: true}

        parsed_body = JSON.parse(response.body)
        expect(parsed_body.length).to eq(1)
      end

      it 'returns all indicators with model associated if model given' do
        model_indicator = create(:indicator)
        scenario = create(:scenario)
        create(:time_series_value, scenario: scenario, indicator: model_indicator)

        get :index, params: {model: scenario.model_id}

        parsed_body = JSON.parse(response.body)
        expect(parsed_body.length).to eq(1)
        expect(parsed_body.dig(0, "id")).to eq(model_indicator.id)
      end

      it 'returns indicators having time series in given scenario and location' do
        scenario = create(:scenario)
        location = create(:location)

        indicator = create(:indicator)
        create(:time_series_value, scenario: scenario, indicator: indicator)
        create(:time_series_value, location: location, indicator: indicator)

        matching_indicator = create(:indicator)
        create(:time_series_value, location: location, scenario: scenario, indicator: matching_indicator)

        get :index, params: {scenario: scenario.id, location: location.id}

        parsed_body = JSON.parse(response.body)
        expect(parsed_body.length).to eq(1)
        expect(parsed_body.dig(0, "id")).to eq(matching_indicator.id)
      end
    end

    describe 'GET show' do
      it 'returns a successful 200 response' do
        get :show, params: {id: some_indicator.id}
        expect(response).to be_success
      end

      it 'returns a 404 not found' do
        get :show, params: {id: -1}
        expect(response).to be_not_found
      end

      it 'shows one indicator' do
        get :show, params: {id: some_indicator.id}
        parsed_body = JSON.parse(response.body)
        expect(parsed_body).to_not be_nil
      end
    end
  end
end


