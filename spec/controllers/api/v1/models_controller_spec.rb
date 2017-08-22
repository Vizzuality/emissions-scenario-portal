require 'rails_helper'

describe Api::V1::ModelsController, type: :controller do
  context do
    let!(:some_models) { FactoryGirl.create_list(:model, 3) }

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
    end

    describe 'GET show' do
      it 'returns a successful 200 response' do
        get :show, params: {id: some_models[0].id}
        expect(response).to be_success
      end

      it 'shows one model' do
        get :show, params: {id: some_models[0].id}
        parsed_body = JSON.parse(response.body)
        expect(parsed_body).to_not be_nil
      end
    end
  end
end
