require 'rails_helper'

RSpec.describe TimeSeriesValuesController, type: :controller do
  context 'when user' do
    login_user

    describe 'GET index' do
      let(:team_model1) { create(:model, team: @user.team) }
      let(:team_model2) { create(:model, team: @user.team) }
      let(:team_scenario1) { create(:scenario, model: team_model1) }
      let(:team_scenario2) { create(:scenario, model: team_model2) }
      let(:indicator) { create(:indicator) }

      it 'returns scenario time series file' do
        create(:time_series_value, scenario: team_scenario)

        get(
          :index,
          params: {model_id: team_model1.id, scenario_id: team_scenario.id}
        )
        expect(response.content_type).to eq('text/csv')
        expect(response.headers['Content-Disposition']).
          to eq('attachment; filename=scenario_time_series_data.csv')
      end

      it 'returns only model specific data' do
        create(:time_series_value, scenario: team_scenario1, indicator: indicator)
        create(:time_series_value, scenario: team_scenario2, indicator: indicator)

        get(
          :index,
          params: {model_id: team_model1.id, indicator_id: indicator.id}
        )
        expect(response.content_type).to eq('text/csv')
        expect(response.headers['Content-Disposition']).
          to eq('attachment; filename=indicator_time_series_data.csv')

        expect(response.body.lines.size).to eq(2)
      end

      it 'returns indicator time series file' do
        create(:time_series_value, indicator: indicator)

        get(
          :index,
          params: {indicator_id: indicator.id}
        )
        expect(response.content_type).to eq('text/csv')
        expect(response.headers['Content-Disposition']).
          to eq('attachment; filename=indicator_time_series_data.csv')
      end
    end
  end
end
