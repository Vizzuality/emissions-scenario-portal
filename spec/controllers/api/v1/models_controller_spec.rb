require 'rails_helper'

describe Api::V1::ModelsController, type: :controller do
  context do
    let!(:some_models) { create_list(:model, 2) }
    let!(:model_with_time_series) {
      my_model = create(:model)
      scenario = create(:scenario, model_id: my_model.id)
      create(:time_series_value, scenario_id: scenario.id)
      my_model
    }

    describe 'GET index' do
      it 'returns a successful 200 response' do
        get :index
        expect(response).to be_success
      end

      it 'lists all models' do
        get :index
        parsed_body = JSON.parse(response.body)
        expect(parsed_body.length).to eq(3)
      end

      it 'filters by models with time_series_values' do
        get :index, params: {time_series: true}
        parsed_body = JSON.parse(response.body)
        expect(parsed_body.length).to eq(1)
      end
    end

    describe 'GET show' do
      it 'returns a successful 200 response' do
        get :show, params: {id: some_models[0].id}
        expect(response).to be_success
      end

      it 'returns a 404 not found' do
        get :show, params: {id: -1}
        expect(response).to be_not_found
      end

      it 'shows one model' do
        get :show, params: {id: some_models[0].id}
        parsed_body = JSON.parse(response.body)
        expect(parsed_body).to_not be_nil
      end
    end
  end
end
