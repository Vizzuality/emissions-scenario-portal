require 'rails_helper'

describe Api::V1::IndicatorsController, type: :controller do
  context do
    let!(:some_indicator) { create(:indicator) }

    describe 'GET index' do
      it 'returns a successful 200 response' do
        get :index
        expect(response).to be_success
      end

      it 'lists all indicators' do
        get :index
        parsed_body = JSON.parse(response.body)
        expect(parsed_body.length).to eq(1)
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


