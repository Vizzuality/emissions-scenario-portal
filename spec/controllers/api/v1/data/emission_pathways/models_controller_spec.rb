require 'rails_helper'

describe Api::V1::Data::EmissionPathways::ModelsController, type: :controller do
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
    end
  end
end
