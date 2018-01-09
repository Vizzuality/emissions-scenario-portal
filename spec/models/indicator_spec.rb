require 'rails_helper'

RSpec.describe Indicator, type: :model do
  context 'validations' do
    it 'should be invalid when category not present' do
      expect(
        build(:indicator, category: nil)
      ).to have(1).errors_on(:category)
    end
  end

  context 'linked scenarios and models' do
    let(:indicator) { create(:indicator) }
    let(:scenario1) { create(:scenario) }
    let!(:scenario2) { create(:scenario) }
    let!(:time_series_value) {
      create(
        :time_series_value, indicator: indicator, scenario: scenario1
      )
    }

    it 'should return scenarios linked to this indicator' do
      expect(indicator.scenarios).to include(scenario1)
      expect(indicator.scenarios.length).to eq(1)
    end

    it 'should return modelslinked to this indicator' do
      expect(indicator.models).to include(scenario1.model)
      expect(indicator.models.length).to eq(1)
    end
  end

  describe :destroy do
    let(:indicator) { create(:indicator) }
    let!(:time_series_value) {
      create(:time_series_value, indicator: indicator)
    }
    it 'should destroy all time series values' do
      expect { indicator.destroy }.to change(TimeSeriesValue, :count).by(-1)
    end
  end

  describe :time_series_data? do
    let!(:indicator) { create(:indicator) }
    it 'returns false when no time series data present' do
      expect(indicator.time_series_data?).to be(false)
    end
    it 'returns true when time series data present' do
      create(:time_series_value, indicator: indicator)
      expect(indicator.time_series_data?).to be(true)
    end
  end

  describe :scenarios do
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
      expect(indicator.scenarios.count).to eq(1)
    end
  end
end
