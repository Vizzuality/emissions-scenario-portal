require 'rails_helper'

RSpec.describe Scenario, type: :model do
  describe :create do
    it 'ignores blank array values' do
      attributes = attributes_for(:scenario).
        merge(technology_coverage: ['', 'A', 'B', 'C'])
      expect(Scenario.create(attributes).technology_coverage.length).to eq(3)
    end
  end

  describe :time_series_data? do
    let(:scenario) { create(:scenario) }
    it 'should be true when time series values present' do
      create(:time_series_value, scenario: scenario)
      expect(scenario.time_series_data?).to be(true)
    end
    it 'should be true when time series values absent' do
      expect(scenario.time_series_data?).to be(false)
    end
  end

  describe :destroy do
    let(:scenario) { create(:scenario) }
    let!(:time_series_value) {
      create(:time_series_value, scenario: scenario)
    }
    it 'should destroy all time series values' do
      expect { scenario.destroy }.to change(TimeSeriesValue, :count).by(-1)
    end
  end

  describe :indicators do
    let(:indicator) { create(:indicator) }
    let(:scenario) { create(:scenario) }
    let!(:time_series_value1) {
      create(
        :time_series_value, indicator: indicator, scenario: scenario
      )
    }
    let!(:time_series_value2) {
      create(
        :time_series_value, indicator: indicator, scenario: scenario
      )
    }
    it 'should not double count' do
      expect(scenario.indicators.count).to eq(1)
    end
  end
end
