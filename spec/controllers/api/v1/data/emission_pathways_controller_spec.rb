require 'rails_helper'

describe Api::V1::Data::EmissionPathwaysController, type: :controller do
  include_context 'emission pathways'

  let :params_for_get do
    {
      location_ids: [spain.id],
      model_ids: [model.id],
      scenario_ids: [scenario.id],
      category_ids: [category_1.id],
      subcategory_ids: [subcategory_1.id],
      indicator_ids: [indicator_1.id],
      start_year: 2020,
      end_year: 2030
    }
  end

  describe 'GET index' do
    it 'renders emission pathways' do
      get :index, params: params_for_get
      expect(response).to be_success
    end

    it 'returns composite_name' do
      get :index, params: params_for_get
      expect(response.body).to include('composite_name')
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

    it 'does not return years below 2005' do
      get :index
      records = JSON.parse(@response.body)['data']
      expect(records.count).to be(3)
      expect(records).not_to include(1970)
    end
  end

  describe 'GET download' do
    it 'returns data as zip' do
      get :download
      expect(response.content_type).to eq('application/zip')
      expect(response.headers['Content-Disposition']).
        to eq('attachment; filename="emission_pathways.zip"')
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
