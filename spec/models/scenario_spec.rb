require 'rails_helper'

RSpec.describe Scenario, type: :model do
  describe :meta_data? do
    let(:scenario) { FactoryGirl.create(:scenario) }
    it 'should be true when metadata present' do
      expect(scenario.meta_data?).to be(true)
    end
    pending 'should be false when some metadata absent'
  end
  describe :time_series_data? do
    let(:scenario) { FactoryGirl.create(:scenario) }
    it 'should be true when time series values present' do
      FactoryGirl.create(:time_series_value, scenario: scenario)
      expect(scenario.time_series_data?).to be(true)
    end
    it 'should be true when time series values absent' do
      expect(scenario.time_series_data?).to be(false)
    end
  end

  describe :date_attribute? do
    it 'release_date should be a date attribute' do
      expect(Scenario.date_attribute?(:release_date)).to be(true)
    end
    it 'platform should not be a date attribute' do
      expect(Scenario.date_attribute?(:platform)).to be(false)
    end
  end

  describe :destroy do
    let(:scenario) { FactoryGirl.create(:scenario) }
    let!(:time_series_value) {
      FactoryGirl.create(:time_series_value, scenario: scenario)
    }
    it 'should destroy all time series values' do
      expect { scenario.destroy }.to change(TimeSeriesValue, :count).by(-1)
    end
  end
end
