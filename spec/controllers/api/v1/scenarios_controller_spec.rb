require 'rails_helper'

describe Api::V1::ScenariosController, type: :controller do
  context do
    let!(:some_model) { create(:model) }

    let!(:some_scenarios) {
      create_list(:scenario, 3, model: some_model)
    }

    describe 'GET index' do
      it 'returns a successful 200 response' do
        get :index
        expect(response).to be_success
      end

      it 'lists all scenarios that belong to one model' do
        get :index, params: {model_id: some_model.id}
        parsed_body = JSON.parse(response.body)
        expect(parsed_body.length).to eq(3)
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

      it 'shows one model' do
        get :show, params: {id: some_scenarios[0].id}
        parsed_body = JSON.parse(response.body)
        expect(parsed_body).to_not be_nil
      end
    end
  end
end
