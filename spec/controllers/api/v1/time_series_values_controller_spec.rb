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
    let!(:model_with_time_series) {
      model = create(:model)
      my_scenario = create(:scenario, model_id: model.id)
      create_list(
        :time_series_value,
        5,
        location: location,
        indicator: indicator,
        scenario: my_scenario
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
        expect(parsed_body.length).to eq(15)
      end

      it 'filters time_series_values by model' do
        get :index, params: {model: model_with_time_series.id}
        parsed_body = JSON.parse(response.body)
        expect(parsed_body.length).to eq(5)
      end

      it 'filters time_series_values by scenario' do
        get :index, params: {scenario: scenario.id}
        parsed_body = JSON.parse(response.body)
        expect(parsed_body.length).to eq(10)
      end

      it 'filters time_series_values by indicator' do
        get :index, params: {indicator: indicator.id}
        parsed_body = JSON.parse(response.body)
        expect(parsed_body.length).to eq(15)
      end
    end
  end
end


