require 'rails_helper'

describe Api::V1::TimeSeriesValuesController, type: :controller do
  context do
    let!(:location) { create(:location) }
    let!(:indicator) { create(:indicator) }
    let!(:scenario) { create(:scenario) }
    let!(:some_time_series_values) {
      create_list(
        :time_series_value,
        3,
        location: location,
        indicator: indicator,
        scenario: scenario
      )
    }
    let!(:model_with_time_series) {
      model = create(:model)
      my_scenario = create(:scenario, model_id: model.id)
      create_list(
        :time_series_value,
        1,
        location: location,
        indicator: indicator,
        scenario: my_scenario,
        year: 2502
      )
      model
    }

    describe 'GET index' do
      it 'returns a successful 200 response' do
        get :index
        expect(response).to be_success
      end

      it 'lists all time series values' do
        get :index
        parsed_body = JSON.parse(response.body)
        expect(parsed_body.length).to eq(4)
      end

      it 'filters time_series_values by model' do
        get :index, params: {model: model_with_time_series.id}
        parsed_body = JSON.parse(response.body)
        expect(parsed_body.length).to eq(1)
      end

      it 'filters time_series_values by scenario' do
        get :index, params: {scenario: scenario.id}
        parsed_body = JSON.parse(response.body)
        expect(parsed_body.length).to eq(3)
      end

      it 'filters time_series_values by indicator' do
        get :index, params: {indicator: indicator.id}
        parsed_body = JSON.parse(response.body)
        expect(parsed_body.length).to eq(4)
      end

      it 'filters time_series_values by year_from' do
        create(:time_series_value, year: 2800)
        get :index, params: {year_from: 2800}
        parsed_body = JSON.parse(response.body)
        expect(parsed_body.length).to eq(1)
      end

      it 'filters time_series_values by year_to' do
        create(:time_series_value, year: 1900)
        get :index, params: {year_to: 1900}
        parsed_body = JSON.parse(response.body)
        expect(parsed_body.length).to eq(1)
      end

      it 'filters time_series_values by years' do
        create(:time_series_value, year: 1900)
        create(:time_series_value, year: 1903)
        get :index, params: {years: '1900,1903'}
        parsed_body = JSON.parse(response.body)
        expect(parsed_body.length).to eq(2)
      end
    end

    describe 'GET index' do
      it 'returns array of years' do
        my_indicator = create(:indicator)
        create(:time_series_value, year: 1900, indicator: my_indicator)
        create(:time_series_value, year: 2600, indicator: my_indicator)
        create(:time_series_value, year: 2600, indicator: my_indicator)
        create(:time_series_value, year: 1901, indicator: my_indicator)
        get :years, params: {indicator: my_indicator.id}
        parsed_body = JSON.parse(response.body)
        expect(parsed_body["years"]).to eq([1900, 1901, 2600])
      end
    end
  end
end
