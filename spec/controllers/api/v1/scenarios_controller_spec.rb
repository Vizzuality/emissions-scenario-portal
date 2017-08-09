require 'rails_helper'

RSpec.describe Api::V1::ScenariosController, type: :controller do
  context do
    let!(:some_model) { FactoryGirl.create(:model) }
    let!(:some_scenarios) { FactoryGirl.create_list(:scenario, 3, model: some_model) }

    describe 'GET index' do
      it 'lists all scenarios that belong to one model' do
        get :index, params: {model_id: some_model.id}
        expect(response.body).to eq(some_scenarios.sort_by(&:updated_at).to_json)
      end
    end
  end
end
