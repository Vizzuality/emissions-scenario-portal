require 'rails_helper'

describe Api::V1::Data::EmissionPathwaysController, type: :controller do
  let(:spain) {
    FactoryBot.create(
      :location, iso_code: 'ES', name: 'Spain'
    )
  }
  let(:model) {
    FactoryBot.create(:model)
  }
  let(:scenario) {
    FactoryBot.create(:scenario, model: model)
  }
  let(:category) { FactoryBot.create(:category, name: 'A') }
  let(:subcategory) {
    FactoryBot.create(:category, name: 'B', parent: category)
  }
  let(:indicator) { FactoryBot.create(:indicator, subcategory: subcategory) }

  describe 'GET index' do
    it 'renders emission pathways' do
      get :index, params: {
        location_ids: [spain.id],
        model_ids: [model.id],
        scenario_ids: [scenario.id],
        category_ids: [category.id],
        subcategory_ids: [subcategory.id],
        indicator_ids: [indicator.id],
        start_year: 2020,
        end_year: 2030
      }
      expect(response).to be_success
    end

    it 'sets pagination headers' do
      get :index
      expect(@response.headers).to include('Total')
    end
  end

  describe 'GET download' do
    it 'returns data as csv' do
      get :download
      expect(response.content_type).to eq('text/csv')
      expect(response.headers['Content-Disposition']).
        to eq('attachment; filename=emission_pathways.csv')
    end
  end

  describe 'HEAD meta' do
    it 'returns a header link with path to data sources' do
      head :meta
      links = response.headers['Link'].split(',')
      models_link = links.find do |l|
        _path, rel = l.split(';')
        rel =~ /meta models/
      end
      expect(models_link).to be_present
    end
  end
end
