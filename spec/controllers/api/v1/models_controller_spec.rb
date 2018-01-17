require 'rails_helper'

describe Api::V1::ModelsController, type: :controller do
  context do
    let!(:model) {
      my_model = create(:model)
      scenario = create(:scenario, model_id: my_model.id, published: true)
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
        expect(parsed_body.length).to eq(1)
      end

      it 'filters by models with time_series_values' do
        get :index, params: {time_series: true}
        parsed_body = JSON.parse(response.body)
        expect(parsed_body.length).to eq(1)
      end

      it 'does not list models without published scenarios' do
        create(:model)
        get :index
        parsed_body = JSON.parse(response.body)
        expect(parsed_body.length).to eq(1)
      end
    end

    describe 'GET show' do
      it 'returns a successful 200 response' do
        get :show, params: {id: model.id}
        expect(response).to be_success
      end

      it 'returns a 404 not found' do
        get :show, params: {id: -1}
        expect(response).to be_not_found
      end

      it 'returns a 404 not found if model has no published scenarios' do
        model = create(:model)
        get :show, params: {id: model.id}
        expect(response).to be_not_found
      end

      it 'shows one model' do
        get :show, params: {id: model.id}
        parsed_body = JSON.parse(response.body)
        expect(parsed_body).to_not be_nil
      end

      it 'returns associated indicators' do
        get :show, params: {id: model.id}
        parsed_body = JSON.parse(response.body)
        expect(parsed_body['indicators']).to match(model.indicators.pluck(:id))
      end
    end
  end
end
