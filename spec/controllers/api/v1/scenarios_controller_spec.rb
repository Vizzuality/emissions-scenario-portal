require 'rails_helper'

describe Api::V1::ScenariosController, type: :controller do
  context do
    let!(:some_model) { create(:model) }

    let!(:some_indicator) {
      create(:indicator)
    }

    let!(:some_scenarios) {
      create_list(:scenario, 2, model: some_model)
    }

    let!(:scenario_with_time_series) {
      my_scenario = create(:scenario, model: some_model)
      create(:time_series_value, scenario_id: my_scenario.id)
      my_scenario
    }

    let!(:scenario_with_indicator) {
      some_scenario = create(:scenario)
      create(:time_series_value, scenario: some_scenario, indicator_id: some_indicator.id)
      some_scenario
    }

    describe 'GET index' do
      it 'returns a successful 200 response' do
        get :index
        expect(response).to be_success
      end

      it 'lists all scenarios that belong to one model' do
        get :index, params: {model_id: some_model.id}
        parsed_body = JSON.parse(response.body)
        expect(parsed_body.length).to eq(4)
      end

      it 'lists all scenarios that have time_series_values associated' do
        get :index, params: {time_series: true}
        parsed_body = JSON.parse(response.body)
        expect(parsed_body.length).to eq(2)
      end

      it 'does not list unpublished scenarios' do
        create(:scenario, published: false)
        get :index
        parsed_body = JSON.parse(response.body)
        expect(parsed_body.length).to eq(4)
      end
    end

    describe 'GET show' do
      it 'returns a successful 200 response' do
        get :show, params: {id: some_scenarios[0].id}
        expect(response).to be_success
      end

      it 'returns a 404 not found' do
        get :show, params: {id: -1}
        expect(response).to be_not_found
      end

      it 'returns a 404 not found if scenario is unpublished' do
        scenario = create(:scenario, published: false)
        get :show, params: {id: scenario.id}
        expect(response).to be_not_found
      end

      it 'shows one model' do
        get :show, params: {id: some_scenarios[0].id}
        parsed_body = JSON.parse(response.body)
        expect(parsed_body).to_not be_nil
      end

      it 'returns associated indicators' do
        get :show, params: {id: scenario_with_time_series.id}
        parsed_body = JSON.parse(response.body)
        expect(parsed_body['indicators']).to match(scenario_with_time_series.indicators.pluck(:id))
      end
    end
  end
end
