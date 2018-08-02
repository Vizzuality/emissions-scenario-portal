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
  let(:category_1) { FactoryBot.create(:category, name: 'Canis') }
  let(:subcategory_1) {
    FactoryBot.create(:category, name: 'lupus', parent: category_1)
  }
  let(:indicator_1) {
    FactoryBot.create(:indicator, subcategory: subcategory_1, name: 'dingo')
  }
  let(:category_2) { FactoryBot.create(:category, name: 'Panthera') }
  let(:subcategory_2) {
    FactoryBot.create(:category, name: 'leo', parent: category_2)
  }
  let(:indicator_2) {
    FactoryBot.create(:indicator, subcategory: subcategory_2, name: 'persica')
  }
  let!(:indicator_1_value) {
    FactoryBot.create(
      :time_series_value,
      scenario: scenario,
      indicator: indicator_1,
      location: spain,
      year: 2030,
      value: 1.0
    )
  }
  let!(:indicator_2_value) {
    FactoryBot.create(
      :time_series_value,
      scenario: scenario,
      indicator: indicator_2,
      location: spain,
      year: 2030,
      value: 2.0
    )
  }

  describe 'GET index' do
    it 'renders emission pathways' do
      get :index, params: {
        location_ids: [spain.id],
        model_ids: [model.id],
        scenario_ids: [scenario.id],
        category_ids: [category_1.id],
        subcategory_ids: [subcategory_1.id],
        indicator_ids: [indicator_1.id],
        start_year: 2020,
        end_year: 2030
      }
      expect(response).to be_success
    end

    it 'sorts by category ascending' do
      get :index, params: {
        sort_col: 'category', sort_dir: 'ASC'
      }
      records = JSON.parse(@response.body)['data']
      expect(records.first['category']).to eq(category_1.name)
    end

    it 'sorts by category descending' do
      get :index, params: {
        sort_col: 'category', sort_dir: 'DESC'
      }
      records = JSON.parse(@response.body)['data']
      expect(records.first['category']).to eq(category_2.name)
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
