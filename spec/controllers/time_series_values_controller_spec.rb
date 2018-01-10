require 'rails_helper'

RSpec.describe TimeSeriesValuesController, type: :controller do
  context 'when user' do
    login_user

    describe 'GET index' do
      let(:team_model) { create(:model, team: @user.team) }
      let(:team_scenario) { create(:scenario, model: team_model) }
      let(:indicator) { create(:indicator) }

      it 'returns scenario time series file' do
        create(:time_series_value, scenario: team_scenario)

        get(
          :index,
          params: {model_id: team_model.id, scenario_id: team_scenario.id}
        )
        expect(response.content_type).to eq('text/csv')
        expect(response.headers['Content-Disposition']).
          to eq('attachment; filename=scenario_time_series_data.csv')
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

      it 'returns model specific indicator time series file' do
        create(:time_series_value, indicator: indicator, scenario: team_scenario)
        create(:time_series_value, indicator: indicator)

        get(
          :index,
          params: {model_id: team_model.id, indicator_id: indicator.id}
        )
        expect(response.content_type).to eq('text/csv')
        expect(response.headers['Content-Disposition']).
          to eq('attachment; filename=indicator_time_series_data.csv')
        expect(response.body.lines.size).to eq(2)
      end
    end
  end
end
