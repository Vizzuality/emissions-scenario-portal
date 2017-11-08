require 'rails_helper'

describe Api::V1::LocationsController, type: :controller do
  context do
    let!(:some_location) { create(:location) }

    describe 'GET index' do
      it 'returns a successful 200 response' do
        get :index
        expect(response).to be_success
      end

      it 'lists all locations' do
        get :index
        parsed_body = JSON.parse(response.body)
        expect(parsed_body.length).to eq(1)
      end
    end
  end
end

