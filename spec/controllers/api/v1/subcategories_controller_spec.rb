require 'rails_helper'

describe Api::V1::SubcategoriesController, type: :controller do
  context do
    let!(:category) { create(:category, :subcategory) }

    describe 'GET index' do
      it 'returns a successful 200 response' do
        get :index
        expect(response).to be_success
      end

      it 'returns categories filtered by location' do
        location = create(:location)
        subcategory_in_location = create(:category, :subcategory)
        indicator = create(:indicator, subcategory: subcategory_in_location)
        create(:time_series_value, location: location, indicator: indicator)

        get :index, params: {location: location.id}

        parsed_body = JSON.parse(response.body)
        expect(parsed_body.length).to eq(1)
        expect(parsed_body.dig(0, "id")).to eq(subcategory_in_location.id)
      end

      it 'returns categories filtered by scenario' do
        scenario = create(:scenario)
        subcategory_in_scenario = create(:category, :subcategory)
        indicator = create(:indicator, subcategory: subcategory_in_scenario)
        create(:time_series_value, scenario: scenario, indicator: indicator)

        get :index, params: {scenario: scenario.id}

        parsed_body = JSON.parse(response.body)
        expect(parsed_body.length).to eq(1)
        expect(parsed_body.dig(0, "id")).to eq(subcategory_in_scenario.id)
      end

      it 'returns categories filtered by location and scenario' do
        location = create(:location)
        scenario = create(:scenario)
        subcategory = create(:category, :subcategory)
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
        expect(parsed_body.dig(0, "id")).to eq(subcategory.id)
      end

      it 'returns categories filtered by parent category' do
        parent_category = create(:category, parent: nil)
        subcategory = create(:category, parent: parent_category)

        get :index, params: {category: parent_category.id}

        parsed_body = JSON.parse(response.body)
        expect(parsed_body.length).to eq(1)
        expect(parsed_body.dig(0, "id")).to eq(subcategory.id)
      end
    end
  end
end
