require 'rails_helper'

# rubocop:disable Metrics/LineLength
describe Api::V1::Data::EmissionPathways::CategoriesController, type: :controller do
  # rubocop:enable Metrics/LineLength
  context do
    let!(:category) { create(:category) }

    describe 'GET index' do
      it 'returns a successful 200 response' do
        get :index
        expect(response).to be_success
      end
    end
  end
end
