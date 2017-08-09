require 'rails_helper'

RSpec.describe Api::V1::ModelsController, type: :controller do
  context do
    let!(:some_models) { FactoryGirl.create_list(:model, 3) }

    describe 'GET index' do
      it 'lists all models' do
        get :index
        expect(response.body).to eq(some_models.sort_by(&:updated_at).to_json)
      end
    end

    describe 'GET show' do
      it 'shows one model' do
        get :show, params: {id: some_models[0].id}
        expect(response.parsed_body).to eq(some_models[0].to_json)
      end
    end
  end
end
