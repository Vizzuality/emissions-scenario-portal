require 'rails_helper'

# rubocop:disable Metrics/LineLength
describe Api::V1::Data::EmissionPathways::ScenariosController, type: :controller do
  # rubocop:enable Metrics/LineLength
  context do
    let!(:some_model) { create(:model) }

    let!(:some_indicator) {
      create(:indicator)
    }

    let!(:some_scenarios) {
      create_list(:scenario, 2, model: some_model)
    }

    let!(:scenario_with_time_series) {
      my_scenario = create(:scenario, model: some_model)
      create(:time_series_value, scenario_id: my_scenario.id)
      my_scenario
    }

    let!(:scenario_with_indicator) {
      some_scenario = create(:scenario)
      create(
        :time_series_value,
        scenario: some_scenario,
        indicator_id: some_indicator.id
      )
      some_scenario
    }

    describe 'GET index' do
      it 'returns a successful 200 response' do
        get :index
        expect(response).to be_success
      end
    end
  end
end
