require 'rails_helper'

describe Api::V1::ScenariosController, type: :controller do
  context do
    let!(:some_model) { create(:model) }

    let!(:some_scenarios) {
      create_list(:scenario, 3, model: some_model)
    }

    describe 'GET index' do
      it 'returns a successful 200 response' do
        get :index, params: {model_id: some_model.id}
        expect(response).to be_success
      end

      it 'lists all scenarios that belong to one model' do
        get :index, params: {model_id: some_model.id}
        parsed_body = JSON.parse(response.body)
        expect(parsed_body.length).to eq(3)
      end
    end
  end
end
