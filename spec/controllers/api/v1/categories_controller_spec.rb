require 'rails_helper'

describe Api::V1::CategoriesController, type: :controller do
  context do
    let!(:category) { create(:category) }

    describe 'GET index' do
      it 'returns a successful 200 response' do
        get :index
        expect(response).to be_success
      end

      it 'returns categories filtered by location' do
        location = create(:location)
        category_in_location = create(:category)
        subcategory = create(:category, parent: category_in_location)
        indicator = create(:indicator, subcategory: subcategory)
        create(:time_series_value, location: location, indicator: indicator)

        get :index, params: {location: location.id}

        parsed_body = JSON.parse(response.body)
        expect(parsed_body.length).to eq(1)
        expect(parsed_body.dig(0, "id")).to eq(category_in_location.id)
      end

      it 'returns categories filtered by scenario' do
        scenario = create(:scenario)
        category_in_scenario = create(:category)
        subcategory = create(:category, parent: category_in_scenario)
        indicator = create(:indicator, subcategory: subcategory)
        create(:time_series_value, scenario: scenario, indicator: indicator)

        get :index, params: {scenario: scenario.id}

        parsed_body = JSON.parse(response.body)
        expect(parsed_body.length).to eq(1)
        expect(parsed_body.dig(0, "id")).to eq(category_in_scenario.id)
      end

      it 'returns categories filtered by location and scenario' do
        location = create(:location)
        scenario = create(:scenario)
        category = create(:category)
        subcategory = create(:category, parent: category)
        indicator = create(:indicator, subcategory: subcategory)
        create(
          :time_series_value,
          scenario: scenario,
          location: location,
          indicator: indicator
        )

        create(
          :time_series_value,
          scenario: scenario,
        )

        create(
          :time_series_value,
          location: location,
        )

        get :index, params: {scenario: scenario.id, location: location.id}

        parsed_body = JSON.parse(response.body)
        expect(parsed_body.length).to eq(1)
        expect(parsed_body.dig(0, "id")).to eq(category.id)
      end
    end
  end
end
